###### 25/Feb/2022
- Added price check feature
- Show me which is the best selling item, the last sold price and the number of sales in the past 3 days

API used - https://universalis.app/docs/index.html?urls.primaryName=Universalis%20v2
eg: https://universalis.app/api/v2/history/ravana/21823?entriesToReturn=800&entriesWithin=300000 number of entries in the past 3 days

![eulmore](https://user-images.githubusercontent.com/21898084/155671185-3dd9f8b3-f5c4-413c-8f18-85fbfbf951a6.gif)

Initial
- Created a Bot to perform repeated tasks, that involves in handing in items to the npc to get currency and buying items with the same currency with another npc.
- Created a local <a href="https://github.com/teoshinjiat/FFXIV-Menu/blob/main/items.json">file</a> that acts as the database, that stores the item definition, so it can support more items in the future
- Image detection using built in imageSearch() to determine what to do next. However the function does not support if the game window is inactive, or simply behind another window(background)
Few days later, the function is upgraded tp Gdip's imageSearch(), which fixed the problem, allowing true botting experience.
