package fight
{
    import conf.cfg_scene;

    import laya.display.Sprite;
    import laya.maths.Point;
    import laya.ui.Image;
    import laya.ui.ProgressBar;

    import manager.GameConst;

    public class WarMap
    {
        public static var _instance:WarMap;
        public var _mapId:Number = 0;
        public var _mapImg:Image;

        public static function get instance():WarMap
        {
            return _instance || (_instance = new WarMap());
        }


        public function WarMap()
        {

        }

        public function initMap(parent:Sprite, sceneid:Number):void
        {
            if (!_mapImg)
            {
                _mapImg = new Image();
                parent.addChild(_mapImg);
            }

            if (_mapId != sceneid)
            {
                _mapId = sceneid;
                var sceneData:cfg_scene = cfg_scene.instance(_mapId + "");
                _mapImg.skin = sceneData.up_img + "";
            }
            screenResize();
        }

        public function screenResize():void
        {
            if (_mapImg)
            {
                _mapImg.width = GameConst.war_with * CoordGm.instance.maxScale;
                _mapImg.height = GameConst.war_height * CoordGm.instance.maxScale;
            }
        }
    }
}