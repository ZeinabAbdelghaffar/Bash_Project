#!/bin/bash

create_database() {
    read -p "Enter the DB name: " dbname
    mkdir "$dbname"
    echo "DB $dbname created successfully."
}

list_databases() {
    echo "List of databases:"
    for database in $(ls -d */ | sed 's#/##'); do
        echo "- $database"
    done
}

connect_to_database() {
    read -p "Enter the DB name: " dbname
    if [ -d "$dbname" ]; then
        cd "$dbname" || exit
        database_menu
    else
        echo "DB $dbname does not exist."
    fi
}

drop_database() {
    read -p "Enter the DB name: " dbname
    if [ -d "$dbname" ]; then
        rm -r "$dbname"
        echo "DB $dbname dropped successfully."
    else
        echo "DB $dbname does not exist."
    fi
}

create_table() {
    read -p "Enter the table name: " table_name
    if [ -e "$table_name" ]; then
        echo "Table $table_name already exists."
    else
        read -p "Enter column names: " column_names
        read -p "Enter data types for columns: " data_types
        header="$column_names|$data_types"
        echo "$header" > "$table_name"
        echo "Table $table_name created successfully."
    fi
}

list_tables() {
    echo "List of tables:"
    for table in $(ls -p | grep -E -v '/$'); do
        echo "- $table"
    done
}

drop_table() {
    read -p "Enter the table name: " table_name
    if [ -e "$table_name" ]; then
        rm "$table_name"
        echo "Table $table_name dropped successfully."
    else
        echo "Table $table_name does not exist."
    fi
}

insert_into_table() {
    read -p "Enter the table name: " table_name
    if [ -e "$table_name" ]; then
        read -p "Enter values for each column: " input_values
        echo "$input_values" >> "$table_name"
        echo "Row inserted into $table_name successfully."
    else
        echo "Table $table_name does not exist. Please create the table first."
    fi
}

select_from_table() {
    read -p "Enter the table name: " table_name
    if [ -e "$table_name" ]; then
        read -p "Enter the PK or leave blank for all rows: " condition
        awk -v cond="$condition" -v header_printed=0 '
            BEGIN { FS = "|" }
            { 
                if (NR == 1 || (cond != "" && $0 !~ cond))
                    next; 
                print
            }
        ' "$table_name"
    else
        echo "Table $table_name does not exist."
    fi
}


delete_from_table() {
    read -p "Enter the table name: " table_name
    read -p "Enter the PK or leave blank for all rows: " condition
    awk -v cond="$condition" '
        BEGIN { FS = "|" }
        { 
            if (cond == "" || $0 !~ cond) {
                print $0
            }
        }
    ' "$table_name" > temp_table && mv temp_table "$table_name"
    echo "Row deleted from $table_name successfully."
}

update_table() {
    read -p "Enter the table name: " table_name
    if [ -e "$table_name" ]; then
        read -p "Enter the PK to identify rows to update: " condition
        if ! awk -v cond="$condition" 'BEGIN { FS = "|" } $0 ~ cond { found = 1; exit } END { exit !found }' "$table_name"; then
            echo "Invalid selection: Primary key '$condition' does not exist in $table_name."
            return 1
        fi
        read -p "Enter the new values for each column: " new_values
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
        echo "Row updated in $table_name successfully."
    else
        echo "Table $table_name does not exist."
    fi
}

database_menu() {
    while true; do
        clear
        PS3="Database Menu: "
        options=("Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table") 
        select opt in "${options[@]}"; do
            case $opt in
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
                *) echo "Invalid option, please select a number from 1 to 7";;
            esac
        done
    done
}

while true; do
    clear
    PS3="Main Menu: "
    options=("Create Database" "List Databases" "Connect To Database" "Drop Database")
    select opt in "${options[@]}"; do
        case $opt in
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
            *) echo "Invalid option, please select a number from 1 to 4";;
        esac
    done
done
