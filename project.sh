
BASE_DIR=~/database

if [ -d "$BASE_DIR" ]; then
    echo "Database directory already exists."
else
    mkdir -p "$BASE_DIR"
    echo "Database directory created at $BASE_DIR."
fi


select choice in create_db list_db drop_db connect_db; 
do
    case $choice in 
        create_db) 
            read -p "Enter database name: " dbname
            if [[ "$dbname" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
                if [ -d "$BASE_DIR/$dbname" ]; then
                    echo "Database already exists."
                else
                    mkdir "$BASE_DIR/$dbname"
                    echo "Database '$dbname' created successfully."
                fi   
            else
                echo "Invalid database name."
            fi
        ;;
        list_db)
            ls -F "$BASE_DIR" | grep '/$'
        ;;
        drop_db)
            read -p "Enter database name to drop: " dbname
            if [[ "$dbname" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
                if [ -d "$BASE_DIR/$dbname" ]; then
                    rm -r "$BASE_DIR/$dbname"
                    echo "Database '$dbname' deleted successfully."
                else
                    echo "Database does not exist." 
                fi   
            else
                echo "Invalid database name."
            fi
        ;;
        connect_db)
       read -p "Enter database name: " dbname
            if [[ "$dbname" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
                if [ -d "$BASE_DIR/$dbname" ]; then
                    cd $BASE_DIR/$dbname
                select choice in create_table list_tables drop_table insert_table select_from_table delete_from_table update_table
                do
                    case $choice in 
                    create_table) 
                            read -p "Enter table name: " tname
                            read -p "Enter number of fields: " num_fields
                            if [[ "$dbname" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
                            if [[ ! -f "$tname" ]]; then
                                touch "$tname"
                                touch "$tname+data"
                                echo "Table '$tname' , '$tname+data' created."
                                tables=""
                                tables="$tables$tname"
                                fields=""
                                types="" 
                                for (( i=1; i<=$num_fields; i++ )); do
                                    read -p "Enter field $i name: " field_name
                                    read -p "Enter type for field $i : " field_type      
                                    if [[ "$field_type" == "int" || "$field_type" == "string" || "$field_type" == "date" || "$field_type" == "float" ]]; then                        
                                    fields="$fields$field_name "
                                    types="$types$field_type "
                                      echo "$fields" >> "$tname"
                                      echo "$types" >> "$tname"
                                      echo "Fields and types written to the table."
                                    else
                                    echo "this fields and types not written ,enter valid types"
                                    fi
                                done
                              
                            else
                                echo "Table '$tname' already exists."
                            fi   
                             else
                                echo "Invalid database name."
                            fi                   
                    ;;
                    list_tables)
                       ls  $BASE_DIR/$dbname 
                       
                    ;;
                    drop_table)
                              read -p "enter table name to remove: " tname
                            if [[ "$tname" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
                                  if [ -f $BASE_DIR/$dbname/$tname ] ;then
                                     rm $BASE_DIR/$dbname/$tname
                                     rm $BASE_DIR/$dbname/$tname+data
                                  else
                                     echo "table name not exist"
                                   fi   
                            else
                                echo "this name is not valid"
                            fi
                            
                    ;;
                     insert_table)
    read -p "Enter the table name you want to insert into: " tabname
    if [[ -f "$BASE_DIR/$dbname/$tabname" && -f "$BASE_DIR/$dbname/$tabname+data" ]]; then
        fields=$(head -n 1 "$BASE_DIR/$dbname/$tabname")
        types=$(tail -n 1 "$BASE_DIR/$dbname/$tabname")
        IFS=' ' read -r -a field_names <<< "$fields"
        IFS=' ' read -r -a field_types <<< "$types"
        num_fields=${#field_names[@]}
        record=""

 
        primary_key_values=()
        while IFS=',' read -r -a row_values; do
            primary_key_values+=("${row_values[0]}")
        done < "$BASE_DIR/$dbname/$tabname+data"

        echo "$num_fields"
        for (( i=0; i<$num_fields; i++ )); do
            while true; do
                read -p "Enter value for ${field_names[$i]} (${field_types[$i]}): " value
                
                
                if [[ $i -eq 0 ]]; then
                    if [[ " ${primary_key_values[@]} " =~ " $value " ]]; then
                        echo "Error: The value for ${field_names[$i]} must be unique. Try again."
                        continue
                    fi
                fi

                
                case "${field_types[$i]}" in
                    int)
                        if [[ "$value" =~ ^[0-9]+$ ]]; then
                            echo "$value is valid"
                        else
                            echo "Invalid integer value"
                            continue
                        fi
                        ;;
                    float)
                        if [[ "$value" =~ ^[0-9]*\.[0-9]+$ ]]; then
                            echo "$value is valid"
                        else
                            echo "Invalid float value"
                            continue
                        fi
                        ;;
                    string)
                        if [[ "$value" =~ ^[a-zA-Z]+$ ]]; then
                            echo "$value is valid"
                        else
                            echo "Invalid string value"
                            continue
                        fi
                        ;;
                    date)
                        if [[ "$value" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                            echo "$value is valid"
                        else
                            echo "Invalid date format (YYYY-MM-DD)"
                            continue
                        fi
                        ;;
                    *)
                        echo "Unknown field type"
                        exit 1
                        ;;
                esac

                
                break
            done
            record+="$value,"
        done

        
        record="${record%,}"
        echo "$record" >> "$BASE_DIR/$dbname/$tabname+data"
        echo "Data inserted into '$tabname'."
    else
        echo "Table '$tabname' does not exist."
    fi
    ;;


                    select_from_table)
                    read -p "enter table name that you want to select from:" tname
                    if [[ -f "$tname" ]]; then
                       select choice in select_all selection projection
                       do
                           case $choice in 
                           select_all) 
                               cat $BASE_DIR/$dbname/$tname+data
                           ;;
                           selection)
                              echo "Available fields in '$tname':"
                              # Load field names from the table structure file
                              fields=$(head -n 1 "$BASE_DIR/$dbname/$tname")
                              IFS=' ' read -r -a field_names <<< "$fields"
                              # Display field names for selection
                              select field in "${field_names[@]}"; do
                                  if [[ -n "$field" ]]; then
                                      echo "You chose field: $field"
                                      break
                                  else
                                      echo "Invalid selection, try again."
                                  fi
                              done
                              # Get the field position (index)
                              field_index=-1
                              for i in "${!field_names[@]}"; do
                                  if [[ "${field_names[$i]}" == "$field" ]]; then
                                      field_index=$i
                                      break
                                  fi
                              done

                              if [[ $field_index -eq -1 ]]; then
                                  echo "Field not found."
                                  continue
                              fi

                              # Ask user for the value to filter by
                              read -p "Enter value to filter by in '$field': " search_value

                              echo "Rows where $field = $search_value:"

                              # Read data and filter rows
                              while IFS=',' read -ra row_values; do
                                  if [[ "${row_values[$field_index]}" == "$search_value" ]]; then
                                      echo "${row_values[*]}"
                                  fi
                              done < "$BASE_DIR/$dbname/$tname+data"
                           ;;
                           projection)
                            fields=$(head -n 1 "$BASE_DIR/$dbname/$tname")
                            IFS=' ' read -r -a field_names <<< "$fields"  
                            selected_positions=()  
                            echo "Select fields you want to project (choose 'Done' when finished):"
                            select field in "${field_names[@]}" "Done"; do
                                if [[ "$field" == "Done" ]]; then
                                    break
                                elif [[ -n "$field" ]]; then
                                    for i in "${!field_names[@]}"; do
                                        if [[ "${field_names[i]}" == "$field" ]]; then
                                            selected_positions+=($((i + 1)))
                                            break
                                        fi
                                    done
                                    echo "Field '$field' added to selection."
                                    echo "choose another selection if you want or 5 to done"
                                else
                                    echo "Invalid selection, please try again."
                                fi
                            done
                            echo "Selected fields: ${selected_positions[*]}"
                            echo "Projected Data:"
                            while IFS=',' read -r -a row_values; do
                                selected_row=()
                                for pos in "${selected_positions[@]}"; do
                                    selected_row+=("${row_values[pos-1]}")
                                done
                                echo "${selected_row[*]}"
                            done < "$BASE_DIR/$dbname/$tname+data"
                            ;;
                            esac
                        done  
                        
                    else echo "table is not exist";
                    fi                       
                    ;; 
                     delete_from_table)
                      read -p "Enter the table name you want to delete from: " tname
                      if [[ -f "$BASE_DIR/$dbname/$tname" ]]; then
                          select option in "Delete by column value" "Empty table"; do
                              case $option in
                                  "Delete by column value")
                                      # Load field names to select a column
                                      fields=$(head -n 1 "$BASE_DIR/$dbname/$tname")
                                      IFS=' ' read -r -a field_names <<< "$fields"
                                      # Display field names and ask user to select one
                                      select field in "${field_names[@]}"; do
                                          if [[ -n "$field" ]]; then
                                              echo "You chose field: $field"
                                              break
                                          else
                                              echo "Invalid selection, try again."
                                          fi
                                      done
                                      # Get the index of the selected column
                                      selection_field=-1
                                      for i in "${!field_names[@]}"; do
                                          if [[ "${field_names[$i]}" == "$field" ]]; then
                                              selection_field=$i
                                              break
                                          fi
                                      done
                                      if [[ $selection_field -eq -1 ]]; then
                                          echo "Field not found."
                                          continue
                                      fi
                                      # Get the value to delete by
                                      read -p "Enter the value to delete rows where $field = value: " delete_value
                                      # Create a temporary file to store remaining rows
                                      temp_file=$(mktemp)
                                      # Read each row, keep only rows that do not match the value in the specified column
                                      while IFS=',' read -ra row_values; do
                                          if [[ "${row_values[$field_index]}" != "$delete_value" ]]; then
                                              echo "${row_values[*]}" >> "$temp_file"
                                          fi
                                      done < "$BASE_DIR/$dbname/$tname+data"
                                      # Replace the original data file with the filtered data
                                      mv "$temp_file" "$BASE_DIR/$dbname/$tname+data"
                                      echo "Rows with $field = $delete_value deleted from '$tname'."
                                      ;;
                                 "Empty table")
                                      # Empty the data file by redirecting nothing into it
                                      > "$BASE_DIR/$dbname/$tname+data"
                                      echo "Table '$tname' is now empty."
                                      ;;
                
                                  *)
                                      echo "Invalid option, please choose again."
                                      ;;
                              esac
                              break
                          done
                      else
                          echo "Table '$tname' does not exist."
                      fi
                  ;;
                    update_table)
                         read -p "Enter table name to update: " tname
                         if [[ -f "$BASE_DIR/$dbname/$tname" ]]; then
                             fields=$(head -n 1 "$BASE_DIR/$dbname/$tname")
                             IFS=' ' read -r -a field_names <<< "$fields"
                             echo "fields: ${field_names[*]}"
                             read -p "Enter the field to search for: " search_field
                             read -p "Enter the value to search for in $search_field: " search_value
                             read -p "Enter the field to update : " update_field
                             read -p "Enter the new value for $update_field: " new_value
                             search_index=-1
                             update_index=-1
                             for i in "${!field_names[@]}"; do
                                 if [[ "${field_names[$i]}" == "$search_field" ]]; then
                                     search_index=$i
                                 fi
                                 if [[ "${field_names[$i]}" == "$update_field" ]]; then
                                     update_index=$i
                                 fi
                             done
                             if [[ $search_index -eq -1 ]]; then
                                 echo "Field '$search_field' not found in table."
                                 continue
                             fi
                             if [[ $update_index -eq -1 ]]; then
                                 echo "Field '$update_field' not found in table."
                                 continue 
                             fi
                             while IFS=',' read -ra row_values; do
                                 if [[ "${row_values[$search_index]}" == "$search_value" ]]; then
                                     row_values[$update_index]="$new_value"
                                 fi
                                 echo "${row_values[*]}" | tr ' ' ',' >> "$BASE_DIR/$dbname/$tname+data.tmp"
                             done < "$BASE_DIR/$dbname/$tname+data"
                             mv "$BASE_DIR/$dbname/$tname+data.tmp" "$BASE_DIR/$dbname/$tname+data"
                             echo "Rows where $search_field = $search_value have been updated in '$tname'."
                         else
                             echo "Table '$tname' does not exist."
                         fi                  
                    ;;
                   esac
                done
                else
                  echo "this db is not exist"
               fi   
            else
               echo "this name is not valid"   
           fi
           ;;
    esac
done

