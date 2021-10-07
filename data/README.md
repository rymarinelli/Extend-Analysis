<h3> This directory will be used to store the base verisons of the data before further processing is done. </h3>

<h4> Data Cleaning Notes </h4>
From the merchants table, one of the keys seems to be incorrectly specified. 
There is a column named sortkey, but this is likely store_id. 
Cleaned with this code chunck

<code>
  merchants$store_id <- stringr::str_remove(merchants$sortkey,"STORE::")
</code>
