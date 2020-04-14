# Explore
Use to manage your foreign tables.

Foreign tables allow you to query external data stored in an object store, from the Advanced SQL Engine. You can make the data available in a structured relational format. 

You can select the following tabs:

- [Preview](#Preview)
- [Schema](#Schema)
- [Metadata](#Metadata)
- [Privileges](#Privileges)

<a name="preview" />

## Preview

Displays a sample of the data from the object store.

<a name="schema" />

## Schema

Displays the schema for a CSV file, when defined, including:
- Name
- Field delimiter (optional)
- Field names (optional)

<a name="metadata" />

## Metadata
Displays mapping information from the selected foreign table, including:
- Location
- Description
- Manifest
- Type
- Path
- Row format

<a name="privileges" />

## Privileges

Allows you to manage and control privilege access to your external data.

To add a new user or role to the table, select **+**, then assign:
- **Select** or **Select With Grant Option** to a specific user 
- **Select** to a role

Select ![Images/kebab-menu.png](Images/kebab-menu.png) > **Edit** to update the privileges for specific user or role.

Select ![Images/kebab-menu.png](Images/kebab-menu.png) > **Revoke** to remove a user or role from the table.

