using Toybox.WatchUi;

class ConnectIQLIFXView extends WatchUi.View {
    // Initial view when app is first loaded
    hidden var mMessage = "Press menu button";
    hidden var mModel;
    hidden var lifx_api;
    var main_menu;
    var main_menu_delegate;
    function initialize(api_obj) {
        WatchUi.View.initialize();
        lifx_api = api_obj;
    }

    // Load your resources here
    function onLayout(dc) {
        mMessage = "Loading data from LIFX...";
        main_menu = gen_main_menu();
        main_menu_delegate = new LifxMainInputDelegate(self.lifx_api);
    }

    // Restore the state of the app and prepare the view to be shown
    function onShow() {
        // Start initial view
        var selection = Application.getApp().getSelection();
        if (selection == null) {
            if (self.lifx_api.auth_ok == true) {
                WatchUi.pushView(main_menu, main_menu_delegate, WatchUi.SLIDE_IMMEDIATE);
                Application.getApp().setSelection(false);
            } else if (self.lifx_api.auth_ok == null){
                mMessage = "Loading data from LIFX...";
            } else {
                mMessage = "Authentication error, Please \nset API Key in settings\nvia Garmin Connect";
            }
        }
        else if (selection == false) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }

    // Update the view
    function onUpdate(dc) {
        System.println("onUpdate() called with lifx_api.auth_ok = " + self.lifx_api.auth_ok);
        if (self.lifx_api.auth_ok == true && self.lifx_api.applying_selection == false) {
            WatchUi.pushView(main_menu, main_menu_delegate, WatchUi.SLIDE_IMMEDIATE);
            Application.getApp().setSelection(false);
        } else {
            System.println("onUpdate() pushing mMessage, lifx_api.applying_selection = " + self.lifx_api.applying_selection);
            if (self.lifx_api.applying_selection == true) {
                mMessage = "Sending signal to LIFX...";
            }
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.clear();
            dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_SYSTEM_TINY, mMessage, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }


    }

    // Called when this View is removed from the screen. Save the
    // state of your app here.
    function onHide() {
        return true;
    }


    function gen_main_menu(){
        // Generates the main menu
        var init_menu = new WatchUi.Menu();
        init_menu.setTitle("Select operation");
        init_menu.addItem("Toggle all lights", :toggle_all_lights);
        init_menu.addItem("Apply a Scene", :apply_scene);
        init_menu.addItem("Toggle a light", :toggle_light);
        init_menu.addItem("Exit", :exit);
        return init_menu;
    }


    function onReceive(args) {
        if (args instanceof Lang.String) {
            mMessage = args;
        }
        else if (args instanceof Dictionary) {
            // Print the arguments duplicated and returned by jsonplaceholder.typicode.com
            var keys = args.keys();
            mMessage = "";
            for( var i = 0; i < keys.size(); i++ ) {
                mMessage += Lang.format("$1$: $2$\n", [keys[i], args[keys[i]]]);
            }
        }
        WatchUi.requestUpdate();
    }
}