package fight
{
    import conf.cfg_scene;

    import control.WxC;

    import laya.display.Sprite;

    import manager.GameConst;
    import manager.GameEvent;
    import manager.GameEventDispatch;

    import model.AccountM;
    import model.FightM;
    import model.LoginM;
    import model.SceneM;

    import control.WxShareC;

    public class WarManager
    {
        public static var _instance:WarManager;

        private var _war_layers:Array;//战斗层
        private var _warRoot:Sprite;//战斗根节点

        private var _mainPlayer:Player;

        private var _dieMonsterNum:Number = 0;

        public function WarManager()
        {

        }

        public function init(root:Sprite, layer:Array):void
        {
            _warRoot = root;
            _war_layers = layer;
        }

        public static function dispose():void
        {
            _instance = null
        }

        public static function get instance():WarManager
        {
            return _instance || (_instance = new WarManager());
        }

        public function gameStart():void
        {
            trace("待机游戏开始");
            Monster._monsterArr = [];
            WarMap.instance.initMap(_war_layers[GameConst.bg_layer_index], LoginM.instance.sceneId);
            _warRoot.visible = true;
            if (!_mainPlayer)
            {
                _mainPlayer = Player.create(_war_layers[GameConst.ball_layer_index])
            }
            _mainPlayer.initPlayerData();
            var config:cfg_scene = cfg_scene.instance("" + LoginM.instance.sceneId);
            for (var i:int = 0; i < config.moster_id.length; i++)
            {
                var one:Monster = Monster.create(_war_layers[GameConst.ball_layer_index], config.moster_id[i], i);
                one.initBlood(config.moster_blood[i]);
            }
        }

        private function mainPlayerDead():void
        {
            _mainPlayer.playerFail();
        }

        public function update(delta):void
        {
            _mainPlayer.update(delta);
            FightUpdate.updateObjs(Monster._monsterArr, delta);
        }

        public function screenResize():void
        {
            WarMap.instance.screenResize();
            FightUpdate.screenResize(GameConst.fixed_update_time)
        }



        public function gameStop():void
        {

        }


        public function get mainPalyer():Player
        {
            return _mainPlayer;
        }
    }
}