<?php

class SecureSession extends SessionHandler {

    protected $key, $name, $cookie;

    public function __construct($key, $name = 'MY_SESSION', $cookie = [])
    {
        $this->key = $key;
        $this->name = $name;
        $this->cookie = $cookie;

        $this->cookie += [
            'lifetime' => 0,
            'path'     => ini_get('session.cookie_path'),
            'domain'   => ini_get('session.cookie_domain'),
            'secure'   => isset($_SERVER['HTTPS']),
            'httponly' => true
        ];

        $this->setup();
    }

    private function setup()
    {
        ini_set('session.use_cookies', 1);
        ini_set('session.use_only_cookies', 1);

        session_name($this->name);

        session_set_cookie_params(
            $this->cookie['lifetime'],
            $this->cookie['path'],
            $this->cookie['domain'],
            $this->cookie['secure'],
            $this->cookie['httponly']
        );
    }

    public function start()
    {
        if (session_id() === '') {
            if (session_start()) {
                return true;
                // return mt_rand(0, 4) === 0 ? $this->refresh() : true; // 1/5
            }
        }

        return false;
    }

    public function forget()
    {
        if (session_id() === '') {
            return false;
        }

        $_SESSION = [];

        setcookie(
            $this->name,
            '',
            time() - 42000,
            $this->cookie['path'],
            $this->cookie['domain'],
            $this->cookie['secure'],
            $this->cookie['httponly']
        );

        return session_destroy();
    }

    public function refresh()
    {
        return session_regenerate_id(true);
    }

    public function read($id)
    {
        if(!preg_match('/^[-,a-zA-Z0-9]{1,128}$/', $id)){
            return false;
        }

        $iv = Configuration::Query('/configuration/security/iv')->item(0)->nodeValue;
        //return openssl_decrypt (parent::read($id), "AES-256-CBC", $this->key, 0, $iv);
        $r = openssl_decrypt (parent::read($id), "AES-256-CBC", $this->key, 0, $iv);
        if($r){
            return $r;
        }
        return '';
    }

    public function write($id, $data)
    {
        $iv = Configuration::Query('/configuration/security/iv')->item(0)->nodeValue;
        return parent::write($id, openssl_encrypt($data, "AES-256-CBC", $this->key, 0, $iv));
    }

    public function isExpired($ttl = 60)
    {
        $last = isset($_SESSION['_last_activity'])
            ? $_SESSION['_last_activity']
            : false;

        if ($last !== false && time() - $last > $ttl * 60) {
            return true;
        }

        $_SESSION['_last_activity'] = time();

        return false;
    }

    public function isFingerprint()
    {
        $agent  = (!empty($_SERVER['HTTP_USER_AGENT'])) ? $_SERVER['HTTP_USER_AGENT'] : 'no-user-agent';
        $remote = (!empty($_SERVER['REMOTE_ADDR'])) ? $_SERVER['REMOTE_ADDR'] : 'no-remote-add'; 
        $hash = md5(
            $agent .
            (ip2long($remote) & ip2long('255.255.0.0'))
        );

        if (isset($_SESSION['_fingerprint'])) {
            return $_SESSION['_fingerprint'] === $hash;
        }

        $_SESSION['_fingerprint'] = $hash;

        return true;
    }

    public function isValid()
    {
        return ! $this->isExpired() && $this->isFingerprint();
    }

    public function get($name)
    {
        $parsed = explode('.', $name);

        $result = $_SESSION;

        while ($parsed) {
            $next = array_shift($parsed);

            if (isset($result[$next])) {
                $result = $result[$next];
            } else {
                return null;
            }
        }

        return $result;
    }

    public function put($name, $value)
    {
        $parsed = explode('.', $name);

        $session =& $_SESSION;

        while (count($parsed) > 1) {
            $next = array_shift($parsed);

            if ( ! isset($session[$next]) || ! is_array($session[$next])) {
                $session[$next] = [];
            }

            $session =& $session[$next];
        }

        $session[array_shift($parsed)] = $value;
    }

    public function drop($name)
    {
        $parsed = explode('.', $name);
        $result = $_SESSION;

        while ($parsed) {
            $next = array_shift($parsed);

            if (isset($result[$next])) {
                unset($_SESSION[$next]);
            } else {
                return null;
            }
        }
        return true;
    }

}
