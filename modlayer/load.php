<?php

/**
* We need to load this classes to handle configuration and system initialization 
*/
require('core/util/util.php');
require('core/util/configuration.php');
require('core/util/pathmanager.php');
require('core/handler/application.php');

/**
* We need to set a bigger memory limit than default (8M)
* to work properly with multidimentional arrays converted to XML and GD image handling
*/
ini_set("memory_limit","256M");


/**
*	Set Error reporting
*/
error_reporting(E_STRICT | E_ALL);
ini_set('track_errors', 1); 

/* Set application path */
PathManager::SetApplicationPath(dirname(dirname(__FILE__)));


/**
*	Register php files to autoload from classes directories
*/
spl_autoload_extensions('.php');
spl_autoload_register();


/**
*	Init Application
*/
Application::Initialize('development');



/**
*	We will handle Errors
*/
set_error_handler(array('MLError', 'ErrorHandler'));
set_exception_handler(array('MLError', 'ExceptionHandler'));
register_shutdown_function(array('MLError', 'ShutdownHandler'));



/**
*	default timezone should be in configuration
*/
date_default_timezone_set(Configuration::Query('/configuration/timezone')->item(0)->nodeValue);

/**
* Start Session
*/
// $path   = '/';
// $subdir = Configuration::Query('/configuration/domain/@subdir');
// if($subdir && $subdir->item(0)->nodeValue !== "") $path .= $subdir->item(0)->nodeValue . '/';

// session_set_cookie_params(0, $path, '', 0, 1);
// ini_set('session.cookie_httponly', 1);

Session::Start();

?>