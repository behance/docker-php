<?php

// NOTE: this file+folder should be replaced by the child app
$stdout = fopen( "php://stdout", 'w' );
$stderr = fopen( "php://stderr", 'w' );

fwrite( $stdout, 'Using STDOUT pipe for output' );
fwrite( $stderr, 'Using STDERR pipe for output' );

echo "PHP Version " . PHP_VERSION;
