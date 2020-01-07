## Editor

Select the system and log in to see the main page.


#### Parts of the Editor

From left to right, Views, the Object Browser, and the Script pane. 
Functions and Opened Scripts are below the Object Browser.
The Results pane is below the Script pane.

#### Views

* 
![btn_Editor_main.png](btn_Editor_main.png) Editor - Returns you to the Editor page.
* 
![btn_Scripts_Editor.png](btn_Scripts_Editor.png) Scripts - Allows you to search for scripts (public scripts in addition to yours).
* 
![btn_History_Editor.png](btn_History_Editor.png) History - Shows a comparison of the last execution of the script with the current changes (only displays executions for the current session).


#### Object Browser
The object browser (left panel) displays the objects (databases, users, tables, views) that you have access to as well as the functions (macros, procedures, analytic functions, and so on) that are available. 

1. Expand the database to see the tables or views.
2. Select ![btn_vp_kabob.png](btn_vp_kabob.png) > **Insights** to see the row count, column types, and DDL for the table or view.

You can select an object and drag it into the Editor to insert the qualified object name.

#### Working with Scripts
In the Script pane, you can:
**Run**
**Save**
**Download Script** (![btn_vp_kabob.png](btn_vp_kabob.png) > **More**)
**Upload Script** (![btn_vp_kabob.png](btn_vp_kabob.png) > **More**)
**+ New Script** 

You can also paste a script into the pane and either run or modify from there.

To use an object from the Object Browser, simply drag it into the Editor to insert the qualified object name.

**Note:** If you do a `select *`, the output is limited to 10,000 rows. 

##### Working with parameters
* Enclose parameters in **${ }**.
  Each parameter displays in a list to the right.
* To define the parameter type, select ![btn_vp_kabob.png](btn_vp_kabob.png) > **Edit**.
* To reorder the parameters, select ![btn_vp_kabob.png](btn_vp_kabob.png) > **Move**.

##### The Results pane

Once you have data in the Results pane, use (![btn_vp_kabob.png](btn_vp_kabob.png) > **More**) to download results as either CSV or JSON.

##### Opened Scripts
The area under the object browser lists the currently open (saved scripts).

