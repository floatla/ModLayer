<?php
class Session {
    
    static $started=false;
    static $session;

    public static function Start()
    {
        try
        {
            $appID = Configuration::GetAppID();

            // Sanitize AppID
            $appID = preg_replace('/[^A-Za-z0-9\-]/', '', $appID);

            /*
                el key para encriptar la session (1er parametro) debe ser de 24 caracteres
            */
            self::$session = new SecureSession('systemcontent000modlayer', $appID);

            ini_set('session.save_handler', 'files');
            session_set_save_handler(self::$session, true);

            $appPath = PathManager::GetApplicationPath();
            $sessDir = Util::DirectorySeparator($appPath . '/modlayer/sessions');
            if (!is_dir($sessDir)){mkdir($sessDir, 0776);}

            session_save_path($sessDir);
            ini_set('session.gc_probability', 1);

            self::$session->start();
        }
        catch(Exception $e){
            throw new Exception($e->getMessage(), 1);
        }
    }

    public static function Set($key, $value) {
        self::$session->put($key, $value);
    }

    public static function Get($key) { 
        return self::$session->get($key);
    }

    public static function Drop($key) {
        self::$session->drop($key);
    }

    public static function Destroy() {
        self::$session->forget();
    }

}