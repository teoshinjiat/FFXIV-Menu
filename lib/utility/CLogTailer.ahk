;https://www.autohotkey.com/boards/viewtopic.php?t=47894

class CLogTailer {
	CurrentLine := 0
	LastSize := 0
	
	__New(logfile, callback){
		this.callback := callback
		this.logfile := logfile
		this.TimerFn := this.WatchLog.Bind(this)
		this.InitialParse()
		fn := this.TimerFn
		SetTimer, % fn, 250
	}
	
	; At the start, scan from the END of the log back towards the start...
	; ... and find the callback for each.
	; If the callback returns TRUE, that line matched a regex, so stop...
	; And set this.CurrentLine to that line number, so WatchLog can pick up from that point
	InitialParse(){
		if (FileExist(this.LogFile)){
			numlines := this.CountLines()
			Loop % numlines {
				ln := numlines + 1 - A_Index
				FileReadLine, line, % this.LogFile, % ln
				ret := this.Callback.call(Trim(line))
				if (ret){
					;OutputDebug % "AHK| Found last entry at line " ln " max=" numlines
					FileGetSize, sz , % this.LogFile
					this.LastSize := sz
					this.CurrentLine := numlines
					return
				}
			}
		}
	}
	
	; After the Initial Parse, all subsequent changes in log file size trigger this method.
	; Read all lines that were added since the last tick, and fire the callback for each
	WatchLog(){
		if (FileExist(this.LogFile)){
			FileGetSize, sz , % this.LogFile
			if (sz == this.LastSize){
				return
			}
			if (sz < this.LastSize){
				; Log got smaller - roll over? Reset CurrentLine to 0 and re-parse whole log
				;OutputDebug % "AHK| Log Rollover detected"
				this.CurrentLine := 0
			}
			this.LastSize := sz
			Loop, read, % this.LogFile
			{
				if (A_Index <= this.CurrentLine)
					continue
				;OutputDebug % "AHK| Processing line " A_Index
				this.CurrentLine := A_Index
				if (A_LoopReadLine == "")
					continue
				;OutputDebug % "AHK| Firing callback for line " A_Index
				this.Callback.call(Trim(A_LoopReadLine))
			}
		}
	}
	
	CountLines(){
		c := 0
		Loop, read, % this.LogFile 
		{
			c++
		}
		return c
	}
}