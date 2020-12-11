package manager
{


    import control.WxC;

    import enums.UiType;

    import laya.debug.tools.StringTool;
    import laya.display.Sprite;
    import laya.net.Loader;
    import laya.utils.ClassUtils;
    import laya.utils.Handler;


    public class UiManager
    {
        private static var _instance:UiManager;
        private var _name:String;
        private var _param:Object;
        private var _panel:*;
        private var _caches:Object;
        private var _basePanelMaxDepth:int = 100;
        private var _noramlUiStepAdd:int = 50;
        private var _noramlUiMaxNum:int = 10;
        private var _fightUiStepAdd:int = 1;
        private var _fightUiMaxNum:int = 30;
        private var _fightUiPageStepAdd:int = 1;
        private var _fightUiPageMaxNum:int = 3;
        private var _dlgUiStepAdd:int = 50;
        private var _dlgUiMaxNum:int = 10;
        private var _guideMaxDepth:int = 30;
        private var _disconnectStepAdd:int = 1;
        private var _disconnectMaxNum:int = 1;
        private var _errorUiMaxDepth:int = 30;
        private var _normalList:Array;
        private var _dlglist:Array;
        private var _effecType:String;
        private var _emptyResUi:Object = new Object();
        private var _uiResReplace:Object = new Object();
        private var _uiUnClear:Object = new Object();

        public function UiManager()
        {
            _caches = new Object();
            _normalList = new Array();
            _dlglist = new Array();

            _emptyResUi["Award"] = true;
            _emptyResUi["GoldTip"] = true;
            _uiUnClear["Load"] = true;
            _uiResReplace["PlotSettle"] = "MatchSettle";
            if (WxC.isInMiniGame())
            {
                _emptyResUi["Load"] = true;
            }

        }

        public static function get instance():UiManager
        {
            return _instance || (_instance = new UiManager());
        }


        //ui界面的资源是否为空
        private function uiResEmpty(name:String):Boolean
        {
            return _emptyResUi[name];
        }


        public function loadView(name:String, param:Object = null, effectType:String = null):void
        {

            _effecType = effectType;
            _name = name;
            _param = param;
            _panel = (_caches[_name] || ClassUtils.getInstance("view." + StringTool.toLowHead(_name) + "." + _name));
            _caches[_name] = _panel;
            if (uiResEmpty(name))
            {
                loadComplete(_panel, name, param);
            }
            else
            {
                if (_name != "HorseTip")
                {
                    GameEventDispatch.instance.event(GameEvent.OpenWait);
                }
                Laya.loader.load(res, Handler.create(this, loadComplete, [_panel, name, param]));
            }


        }


        private function loadComplete(pan:Object, name:String, param:Object):void
        {
            pan.EffectType = _effecType;
            removieFromList(pan);
            pan.startGame(param, name);
            pan.setPanelBaseDepth(getNextBaseDepth(pan.uiType));
            addUiToList(pan);
            GameEventDispatch.instance.event(GameEvent.LoadUi, name);
        }

        public function loadUi(Panel:Class, param:Object = null):void
        {
            _panel = new Panel();

            var arr:Array = Panel.prototype.__className.split('.');
            _name = arr[arr.length - 1];
            Laya.loader.load(res, Handler.create(this, loadComplete));


        }


        //游戏各种界面的基础层级
        private function getUiBaseDepth(type:String):int
        {
            var ret:int = 0;
            switch (type)
            {
                case UiType.UI_TYPE_BASE:
                {
                    ret = 0;
                    break;
                }
                case UiType.UI_TYPE_NORMAL:
                {
                    ret = _basePanelMaxDepth;
                    break;
                }
                case UiType.UI_TYPE_FIGHT:
                {
                    ret = getUiBaseDepth(UiType.UI_TYPE_NORMAL) + _noramlUiMaxNum * _noramlUiStepAdd;
                    break;
                }
                case UiType.UI_TYPE_FIGHT_PAGE:
                {
                    ret = getUiBaseDepth(UiType.UI_TYPE_FIGHT) + _fightUiMaxNum * _fightUiStepAdd;
                    break;
                }
                case UiType.UI_TYPE_DLG:
                {
                    ret = getUiBaseDepth(UiType.UI_TYPE_FIGHT_PAGE) + _fightUiPageMaxNum * _fightUiPageStepAdd;
                    break;
                }
                case UiType.UI_TYPE_GUIDE:
                {
                    ret = getUiBaseDepth(UiType.UI_TYPE_DLG) + _dlgUiMaxNum * _dlgUiStepAdd;
                    break;
                }
                case UiType.UI_TYPE_DISCONNECT:
                {
                    ret = getUiBaseDepth(UiType.UI_TYPE_GUIDE) + _guideMaxDepth;
                    break;
                }
                case UiType.UI_TYPE_ERROR_TIP:
                {
                    ret = getUiBaseDepth(UiType.UI_TYPE_DISCONNECT) + _disconnectStepAdd * _disconnectMaxNum;
                    break;
                }
                case UiType.UI_TYPE_MSG_TIP:
                {
                    ret = getUiBaseDepth(UiType.UI_TYPE_ERROR_TIP) + _errorUiMaxDepth;
                    break;
                }
                default:
                {
                    break;
                }
            }
            return ret;
        }

        public function getFightBaseDepth():int
        {
            return getUiBaseDepth(UiType.UI_TYPE_FIGHT);
        }

        public function getFightUiBaseDepth():int
        {
            return getUiBaseDepth(UiType.UI_TYPE_FIGHT_PAGE);
        }

        private function getNextBaseDepth(type:String):int
        {
            var ret:int = 0;
            switch (type)
            {
                case UiType.UI_TYPE_BASE:
                {
                    ret = 0;
                    break;
                }
                case UiType.UI_TYPE_NORMAL:
                {
                    ret = _basePanelMaxDepth + _normalList.length * _noramlUiStepAdd;
                    break;
                }
                case UiType.UI_TYPE_FIGHT:
                {
                    ret = getUiBaseDepth(UiType.UI_TYPE_FIGHT);
                    break;
                }
                case UiType.UI_TYPE_FIGHT_PAGE:
                {
                    ret = getUiBaseDepth(UiType.UI_TYPE_FIGHT_PAGE);
                    break;
                }
                case UiType.UI_TYPE_DLG:
                {
                    ret = getUiBaseDepth(UiType.UI_TYPE_DLG) + _dlglist.length * _dlgUiStepAdd;
                    break;
                }
                case UiType.UI_TYPE_GUIDE:
                {
                    ret = getUiBaseDepth(UiType.UI_TYPE_GUIDE);
                    break;
                }
                case UiType.UI_TYPE_DISCONNECT:
                {
                    ret = getUiBaseDepth(UiType.UI_TYPE_DISCONNECT);
                }
                case UiType.UI_TYPE_MSG_TIP:
                {
                    ret = getUiBaseDepth(UiType.UI_TYPE_MSG_TIP);
                    break;
                }
                case UiType.UI_TYPE_ERROR_TIP:
                {
                    ret = getUiBaseDepth(UiType.UI_TYPE_ERROR_TIP);
                    break;
                }
                default:
                {
                    break;
                }
            }
            return ret;
        }


        private function removieFromList(panel:*):void
        {
            switch (panel.uiType)
            {
                case UiType.UI_TYPE_NORMAL:
                {
                    if (_normalList.indexOf(panel) != -1)
                    {
                        _normalList.splice(_normalList.indexOf(panel), 1);
                        resetBasePanelDepth(_normalList, getUiBaseDepth(UiType.UI_TYPE_NORMAL), _noramlUiStepAdd);
                    }
                    break;
                }
                case UiType.UI_TYPE_DLG:
                {
                    if (_dlglist.indexOf(panel) != -1)
                    {
                        _dlglist.splice(_dlglist.indexOf(panel), 1);
                        resetBasePanelDepth(_dlglist, getUiBaseDepth(UiType.UI_TYPE_DLG), _dlgUiStepAdd);
                    }
                    break;
                }
                default:
                {
                    break;
                }
            }
        }


        private function get pngNum():int
        {
            return _panel.pngNum
        }

        private function get res():Array
        {
            var uiRes:String = _name;
            if (_uiResReplace[_name])
            {
                uiRes = _uiResReplace[_name];
            }

            var arr:Array = [{url: "res/atlas/ui/" + StringTool.toLowHead(uiRes) + ".atlas", type: Loader.ATLAS}];
            for (var i:int = 0; i < pngNum; i++)
            {
                arr.push({
                    url: "ui/" + StringTool.toLowHead(_name) + "/" + StringTool.toLowHead(_name) + "_" + i + ".png",
                    type: Loader.IMAGE
                });
            }
            return arr;
        }

        public function unloadView():void
        {

        }

        private function addUiToList(panel:*):void
        {
            switch (panel.uiType)
            {
                case UiType.UI_TYPE_NORMAL:
                {
                    if (_normalList.indexOf(panel) == -1)
                    {
                        _normalList.push(panel);
                    }
                    break;
                }
                case UiType.UI_TYPE_DLG:
                {
                    if (_dlglist.indexOf(panel) == -1)
                    {
                        _dlglist.push(panel);
                    }
                    break;
                }
                default:
                {
                    break;
                }
            }
        }

        private function resetBasePanelDepth(list:Array, baseDepth:int, stepAdd:int):void
        {
            for (var i:int = 0; i < list.length; i++)
            {
                list[i].setPanelBaseDepth(baseDepth);
                baseDepth += stepAdd;
            }

        }

        public function closePanel(name:String, isRemovie:Boolean):void
        {
            var panel:* = _caches[name];
            if (panel != null)
            {
                removieFromList(panel);
                if (isRemovie)
                {
                    panel.removie();
                }
                else
                {
                    panel.hide();
                }
                GameEventDispatch.instance.event(GameEvent.CloseUi, name);
            }
            if (_uiUnClear[name])
            {
                return;
            }
            if (_uiResReplace[name])
            {

                Laya.loader.clearTextureRes("res/atlas/ui/" + StringTool.toLowHead(_uiResReplace[name]) + ".png");
            }
            else
            {

                Laya.loader.clearTextureRes("res/atlas/ui/" + StringTool.toLowHead(name) + ".png");
            }

        }

        public function isUiShowing(uiName:String):Boolean
        {
            var tmpNode:Sprite = Laya.stage.getChildByName(uiName) as Sprite;
            if (tmpNode)
            {
                return tmpNode.visible;
            }
            return false;
        }

    }
}
