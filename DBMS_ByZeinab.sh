#!/bin/bash

create_database() {
    dbname=$(zenity --entry --title="Create Database" --text="Enter the DB name:")
    if [ -n "$dbname" ]; then
        mkdir "$dbname"
        zenity --info --title="Success" --text="Database $dbname created successfully."
    else
        zenity --warning --title="Warning" --text="Database name cannot be empty."
    fi
}

list_databases() {
    database=$(ls -d */ | sed 's#/##')
    zenity --info --title="List of Databases" --text="List of databases:\n$databases"
}

connect_to_database() {
    dbname=$(zenity --entry --title="Connect to Database" --text="Enter the DB name:")
    if [ -d "$dbname" ]; then
        cd "$dbname" || exit
        database_menu
    else
        zenity --error --title="Error" --text="Database $dbname does not exist."
    fi
}

drop_database() {
    dbname=$(zenity --entry --title="Drop Database" --text="Enter the DB name:")
    if [ -d "$dbname" ]; then
        rm -r "$dbname"
        zenity --info --title="Success" --text="Database $dbname dropped successfully."
    else
        zenity --error --title="Error" --text="Database $dbname does not exist."
    fi
}

create_table() {
    table_name=$(zenity --entry --title="Create Table" --text="Enter the table name:")
    if [ -n "$table_name" ]; then
        if [ -e "$table_name" ]; then
            zenity --warning --title="Warning" --text="Table $table_name already exists."
        else
            column_names=$(zenity --entry --title="Enter Column Names" --text="Enter column names:")
            data_types=$(zenity --entry --title="Enter Data Types" --text="Enter data types for columns:")
            header="$column_names|$data_types"
            echo "$header" > "$table_name"
            zenity --info --title="Success" --text="Table $table_name created successfully."
        fi
    else
        zenity --warning --title="Warning" --text="Table name cannot be empty."
    fi
}

list_tables() {
    table=$(ls -p | grep -E -v '/$')
    zenity --info --title="List of Tables" --text="List of tables:\n$tables"
}

drop_table() {
    table_name=$(zenity --entry --title="Drop Table" --text="Enter the table name:")
    if [ -e "$table_name" ]; then
        rm "$table_name"
        zenity --info --title="Success" --text="Table $table_name dropped successfully."
    else
        zenity --error --title="Error" --text="Table $table_name does not exist."
    fi
}

insert_into_table() {
    table_name=$(zenity --entry --title="Insert into Table" --text="Enter the table name:")
    if [ -e "$table_name" ]; then
        input_values=$(zenity --entry --title="Insert into Table" --text="Enter values for each column:")
        echo "$input_values" >> "$table_name"
        zenity --info --title="Success" --text="Row inserted into $table_name successfully."
    else
        zenity --error --title="Error" --text="Table $table_name does not exist. Please create the table first."
    fi
}

select_from_table() {
    table_name=$(zenity --entry --title="Select From Table" --text="Enter the table name:")
    if [ -e "$table_name" ]; then
        condition=$(zenity --entry --title="Select From Table" --text="Enter the PK or leave blank for all rows:")
        if [ -z "$condition" ]; then
            cat "$table_name" | zenity --text-info --title="Table Content" --width=400 --height=300
        else
            awk -v cond="$condition" '
               BEGIN { FS = "|" }
               {
                   if ($0 ~ cond)
                       print
               }
            ' "$table_name"
        fi
    else
        zenity --error --title="Error" --text="Table $table_name does not exist."
    fi
}


delete_from_table() {
    table_name=$(zenity --entry --title="Delete From Table" --text="Enter the table name:")
    condition=$(zenity --entry --title="Delete From Table" --text="Enter the PK or leave blank for all rows:")
    awk -v cond="$condition" '
        BEGIN { FS = "|" }
        { 
            if (cond == "" || $0 !~ cond) {
                print $0
            }
        }
    ' "$table_name" > temp_table && mv temp_table "$table_name"
    zenity --info --title="Success" --text="Row deleted from $table_name successfully."
}

update_table() {
    table_name=$(zenity --entry --title="Update Table" --text="Enter the table name:")
    if [ -e "$table_name" ]; then
        condition=$(zenity --entry --title="Update Table" --text="Enter the PK to identify rows to update:")
        if ! awk -v cond="$condition" 'BEGIN { FS = "|" } $0 ~ cond { found = 1; exit } END { exit !found }' "$table_name"; then
            zenity --error --title="Error" --text="Invalid selection: Primary key '$condition' does not exist in $table_name."
            return 1
        fi
        new_values=$(zenity --entry --title="Update Table" --text="Enter the new values for each column:")
        awk -v cond="$condition" -v new_vals="$new_values" '
            BEGIN { FS = "|" }
            {
                if (cond == "" || $0 ~ cond) {
                    split(new_vals, new_val_array, "|")
                    for (i = 1; i <= NF; i++) {
                        if (new_val_array[i] != "") {
                            $i = new_val_array[i]
                        }
                    }
                    sep = ""
                    for (i = 1; i <= NF; i++) {
                        printf "%s%s", sep, $i
                        sep = " | "
                    }
                    printf "\n"
                }
                else {
                    print $0
                }
            }
        ' "$table_name" > temp_table && mv temp_table "$table_name"
        zenity --info --title="Success" --text="Row updated in $table_name successfully."
    else
        zenity --error --title="Error" --text="Table $table_name does not exist."
    fi
}

database_menu() {
    while true; do
        choice=$(zenity --list --title="Database Menu" --column="Options" "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table")
        case $choice in
                "Create Table")
                    create_table
                    ;;
                "List Tables")
                    list_tables
                    ;;
                "Drop Table")
                    drop_table
                    ;;
                "Insert into Table")
                    insert_into_table
                    ;;
                "Select From Table")
                    select_from_table
                    ;;
                "Delete From Table")
                    delete_from_table
                    ;;
                "Update Table")
                    update_table
                    ;;
                *) zenity --warning --title="Warning" --text="Invalid option. Please choose again.";;
        esac
    done
}

while true; do
    choice=$(zenity --list --title="Main Menu" --column="Options" "Create Database" "List Databases" "Connect To Database" "Drop Database")
    case $choice in
            "Create Database")
                create_database
                ;;
            "List Databases")
                list_databases
                ;;
            "Drop Database")
                drop_database
                ;;
            "Connect To Database")
                connect_to_database
                ;;
            *) zenity --warning --title="Warning" --text="Invalid option. Please choose again.";;
    esac
done
