<?php

// NOTE: this file+folder should be replaced by the child app
$stdout = fopen( "php://stdout", 'w' );
$stderr = fopen( "php://stderr", 'w' );

fwrite( $stdout, 'Using STDOUT pipe for output' );
fwrite( $stderr, 'Using STDERR pipe for output' );

phpinfo();

// Use the below form to test uploads
?>

<form method="post" action="/" enctype="multipart/form-data">
  <p>
  Please specify a file, or a set of files:<br>
  <input type="file" name="datafile">
  </p>
  <div>
  <input type="submit" value="Send">
  </div>
</form>
