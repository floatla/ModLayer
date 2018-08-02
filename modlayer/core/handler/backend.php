<?php
abstract class BackEnd //BackEnd
{
    /**
     * The template to be rendered
     * 
     * @var Templates
     */
    static $template;
    
    /**
     * Module Configuration
     * 
     * @var DOMNode
     */
    static $module;

    
    /**
     * 
     * @param type $baseXsl
     * @param type $internalCall
     */
    public static function loadAdminInterface($baseXsl = false, $internalCall = false, $modXSL = false)
    {

        self::$module   = Configuration::GetModuleConfiguration(Application::GetModule());
        self::$template = new Templates();
        self::$template->setDevice('ui');
        
        self::CheckUserAccess($internalCall);


        // Seteamos el path del modulo para la carga de los xsl
        $path = ($modXSL) ? Configuration::GetModuleConfiguration($modXSL) : self::$module;
        self::$template->setpath(PathManager::GetFrameworkPath() . $path->getAttribute('path'));

        self::SetParameters();
        self::SetConfiguration();

        self::SetContext();
        self::SetStylesheets($baseXsl);

        if(!$baseXsl)
            self::SetModulesNavigation();
    }


    /**
     * Validates user access to Module
     * 
     * @param type $module
     * @param bool $internalCall 
     * 
     * @return void
    */
    public static function CheckUserAccess($internalCall = false)
    {
        $user = false;
        $validAccess = false;
        if($user = Admin::Logged()) {
            self::$template->setconfig(Admin::Logged($clearArr=false), null, 'user');
        }

        $access_value = Configuration::Query(
            "/module/options/group[@name='settings']/option[@name='access_level']", 
            self::$module
        );
        
        if($access_value) {
            $accessLevel = $access_value->item(0)->getAttribute('value');
        } else {
            $accessLevel = 'all';
        }
        
        if(! Application::LoginScreen())
        {
            $levels = new AdminLevels();
            $validAccess = $levels->validateAccesLevel($user['access'], $accessLevel);
            
            if($internalCall) { 
                $validAccess = true;
            }
            if(!$validAccess) {
                echo "You dont have access to this area";
                die();
            }
        }      
    }

    /**
     * Prepare all config nodes for the template object.
     * 
     * @see self:$template
    */
    public static function SetConfiguration()
    {
        self::$template->setconfig(self::$module, $xpath=null, $target=null);

        $sysConf = Configuration::Query("/configuration/*[not(*)]");
        self::$template->setconfig($sysConf, null, 'system');

        /* Debug para backend */
        self::$template->debug = Configuration::Query("/configuration/backend_debug")->item(0)->nodeValue;
        
        // Incluimos la configuracion del admin
        $adminConf = Configuration::Query("/configuration/modules/module[@name='admin']/*");
        self::$template->setconfig($adminConf, $xpath=null, $node='admin');

        // Incluimos la configuracion del lenguaje del modulo
        $modLang = Configuration::Query("/configuration/mod_language/*");
        if($modLang){
            self::$template->setconfig($modLang, $xpath=null, 'mod_language');
        }

        // Incluimos la configuracion del lenguaje general
        $language = Configuration::Query("/configuration/language/*");
        if($language)
            self::$template->setconfig($language, $xpath=null, 'language');

    }

    /**
     * Sets all template parameters
     * 
     * @param type $module
     */
    public static function SetParameters()
    {
        //PageUrl
        $request     = (! empty($_SERVER["REQUEST_URI"])) ? $_SERVER["REQUEST_URI"] : "";
        $adminModule = Configuration::GetModuleConfiguration('admin');
        $len         = strlen(PathManager::GetFrameworkDir());

        if(strpos($request, '?')) {
            $request = substr($request, 0, strpos($request, '?'));
        }

        $adminPath = Configuration::Query('/configuration/adminpath');
        $subdir    = Configuration::Query('/configuration/domain/@subdir');

        $path      = ($subdir) ? $subdir->item(0)->nodeValue . $adminPath->item(0)->nodeValue : $adminPath->item(0)->nodeValue;
        $adminRoot  = Util::DirectorySeparator($path, true);

        /* Para el parametro skinpath agregamos el release */
        $release = Configuration::Query('/configuration/release')->item(0)->nodeValue;

        $modPath = '/_r' . $release . substr( PathManager::GetFrameworkDir(), 0, $len ) . self::$module->getAttribute('path');
        $admPath = '/_r' . $release . substr( PathManager::GetFrameworkDir(), 0, $len ) . $adminModule->getAttribute('path');

        self::$template->setparam(
            array(
                'modPath'   => $modPath,
                'modName'   => self::$module->getAttribute('name'),
                'modToken'  => Application::generateToken(),
                'page_url'  => $request,
                'adminPath' => $admPath,
                'adminroot' => $adminRoot,
            )
        );
    }

    /**
     * Add $_GET and lang to {@link self::$template}'s context node.
     */
    public static function SetContext()
    {
        // self::$template->setcontext('<lang>es</lang>', null, null);
        self::$template->setcontext(Encoding::toUTF8($_GET), null, 'get_params');
        self::$template->setcontext(Encoding::toUTF8($_COOKIE), null, 'cookies');
    }

    /**
     * Add stylesheets to template
     * 
     * @param string $baseXsl 
     */
    public static function SetStylesheets($baseXsl = false)
    {
        $device   = self::$template->getDevice();
        $includes = Configuration::QueryGroup('include', 'admin');

        // Si no recibimos un xsl base, cargamos la interfaz standard
        $path = PathManager::GetModuleAdminPath();
        if($baseXsl)
        {
            self::$template->setBaseStylesheet(
                self::$template->getpath() . '/' . $device . '/xsl/' . $baseXsl
            );
        }
        else
        {
            // Seteamos el xsl base
            self::$template->setBaseStylesheet($path . $device . '/xsl/core/layout.xsl');

            if($includes)
            {
                foreach($includes as $option){
                    if($option->getAttribute('always') == 'false'){
                        $file = $path . $device . $option->getAttribute('value');
                        if(!file_exists($file)) die('Include configuration error => XSL path not valid: ' . $file);
                        self::$template->addStylesheet($file);
                    }
                    
                }
            }
        }
        
        if($includes)
        {
            foreach($includes as $option){
                if($option->getAttribute('always') == 'true'){
                    $file = $path . $device . $option->getAttribute('value');
                        if(!file_exists($file)) die('Include configuration error => XSL path not valid: ' . $file);
                        self::$template->addStylesheet($file);
                }
                
            }
        }

        if(self::$template->debug == 1)
            self::$template->addStylesheet($path . $device . '/debug/debug.xsl');
        
    }


    private static function SetModulesNavigation()
    {
        $modules = Configuration::Query('/configuration/modules/module');

        $navigationArr = array();
        $user = Admin::Logged();

        $userAccessLevel = $user['access'];
        $userHasAccess = false;
        
        foreach($modules as $mod)
        {
            $moduleAccessLevel = false;
            $option = Configuration::Query("/module/options/option[@name='access_level']", $mod);

            if($option) {
                $moduleAccessLevel =  $option->item(0)->getAttribute('value');
                $levels = new AdminLevels();
                $userHasAccess = $levels->validateAccesLevel($userAccessLevel,$moduleAccessLevel);
            } else {
                $userHasAccess = true;
            }

            if($userHasAccess && $mod->getAttribute('active') == 1)
            {
                $navigation = Configuration::Query("/module/options/group[@name='navigation']/option[@name='item']",$mod);
                $group      = Configuration::Query("/module/options/group[@name='navigation']",$mod);
                $access     = Configuration::Query("/module/options/group[@name='settings']/option[@name='access_level']",$mod);
                $item_access = ($access) ? $access->item(0)->getAttribute('value') : false; 
                if($group)
                {
                    $arr = array(
                        'name-att'  => (string)$mod->getAttribute('name'),
                        'label-att' => Configuration::ModuleEvalTranslate((string)$group->item(0)->getAttribute('label'), $mod),
                        'group-att' => (string)$group->item(0)->getAttribute('group'),
                        'order-att' => (string)$group->item(0)->getAttribute('order'),
                    );
                    if($item_access){
                        $arr['access_level-att'] = $item_access;
                    }
                    if($navigation)
                    {
                        foreach($navigation as $nav)
                        {
                            //$name = $nav->getAttribute('name');
                            $sub = array(
                                'name-att' => Configuration::ModuleEvalTranslate((string)$nav->getAttribute('label'), $mod),
                                'url-att'  => (string)$nav->getAttribute('url'),
                                'access_level-att'  => (string)$nav->getAttribute('access_level')
                            );
                            array_push($arr, $sub);
                        }
                        $arr['tag']='subitem';
                    }
                    array_push($navigationArr, $arr);
                }
            }
        }
        
        $navigationArr['tag']='item';
        self::$template->setconfig($navigationArr, null, 'navigation');
    }



}
