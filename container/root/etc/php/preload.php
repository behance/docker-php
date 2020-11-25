<?php
/**
 * Sends all eligible files into PHP's opcode cache before server startup
 */
$LOGPREFIX = '[opcache]';
$MEMORY_USAGE_WARNING_PERCENTAGE = 85;
$app_root = getenv('APP_ROOT');

if (!$app_root) {
  echo("${LOGPREFIX} cannot preload, APP_ROOT is empty");
  return;
}

echo "${LOGPREFIX} preloading from ${app_root}\n";
$start_time = microtime(true);

[ $count, $success, $failure ] = compileFiles($app_root);

$end_time = microtime(true);
$elapsed = ($end_time - $start_time);
$elapsed = round($elapsed, 3);

echo "${LOGPREFIX} preloaded: processed ${count} files - ${success} successful / ${failure} failed, in ${elapsed} seconds\n";

$opcache_status = opcache_get_status(false);
$memory_usage = $opcache_status['memory_usage'] ?? [];

if (empty($memory_usage)) {
  echo "${LOGPREFIX} error: no memory reported\n";
  return;
}

$free_memory = $memory_usage['free_memory'] ?? 0;
$wasted_memory = $memory_usage['wasted_memory'] ?? 0;
$used_memory = $memory_usage['used_memory'] ?? 0;

$memory_total = $wasted_memory + $free_memory + $used_memory;
$memory_consumed = $used_memory + $wasted_memory;
$percentage_used = ($memory_consumed / $memory_total) * 100;
$percentage_used = round($percentage_used, 2);

if ($percentage_used >= $MEMORY_USAGE_WARNING_PERCENTAGE) {
  echo "${LOGPREFIX} warning: ${percentage_used}% memory usage, consider raising PHP_OPCACHE_MEMORY_CONSUMPTION env variable\n";
} else {
  echo "${LOGPREFIX} complete: ${percentage_used}% memory utilized\n";
}

function compileFiles($input) {
  $directory = new RecursiveDirectoryIterator($input);
  $fullTree = new RecursiveIteratorIterator($directory);

  $phpunit_filter = '/^(?:(?!test).)*\.php$/i'; // Removes PHPUnit-style filenames (ie. calculatortest.php)

  $all_files = new RegexIterator($fullTree, $phpunit_filter, RecursiveRegexIterator::GET_MATCH);
  $success = 0;
  $failure = 0;
  $results = [];

  foreach($all_files as $file) {
    if (@opcache_compile_file($file[0])) {
      ++$success;
    } else {
      ++$failure;
    }
  }

  $count = $success + $failure;

  return [ $count, $success, $failure ];
}