


## 27/Feb/2022 Initial Release
![image](https://user-images.githubusercontent.com/21898084/155884628-5c08a030-4e30-44c8-a04c-cd67f1cf4fba.png)
The principle of the script is to based on my db file, formulate its crafting cost and display the expected profits for each craft

1) Read items from 
  - purpose of the file is to store items that are craftable, its required materials and the required quantity of each material
  - all item ID are retrieved from <a href="https://github.com/xivapi/ffxiv-datamining/blob/master/csv/Item.csv">a crowdsourced database</a> 
2) Get the current selling price in my world for each crafted item via https://universalis.app/docs/index.html
  - so that I know which item sells the most
3) Get the current selling price of the materials from the other world via https://universalis.app/docs/index.html
  - so that I know which world have the cheapest materials
4) Calculate the above variables and formulate the result then display on the Gui

