package fight.zuma
{
    import conf.cfg_goods;
    import conf.cfg_path;

    import enums.BallDepth;

    import fight.CachePool;
    import fight.CoordGm;
    import fight.FightBase;

    import laya.display.Sprite;
    import laya.maths.Point;
    import laya.ui.Image;

    import manager.GameConst;

    import manager.GameTools;

    public class RoadBlock extends FightBase
    {
        //图片
        private var _ani:Image;
        private var _width:Number = 0;
        private var _height:Number = 0;
        private var _roration:Number = 0;
        //goods表id
        private var _id:Number;
        //设计位置
        private var _curPos:Point = new Point();
        //屏幕位置
        private var _screenPos:Point = new Point();

        //第一次经过障碍物的路程线段【进入障碍物线段，离开障碍物线段】
        private var _oneDistance:Array = [];//必是从下部穿过
        //第二次经过障碍物的路程线段
        private var _twoDistance:Array = [];//必是从上部穿过

        private var _depth:Number = BallDepth.MIDDLE;

        private var _lineSprite:Sprite;

        public function RoadBlock()
        {

        }

        public static function creat(root:Sprite, pathData:cfg_path, index:Number):RoadBlock
        {
            var ret:RoadBlock = CachePool.GetCache("RoadBlock", null, RoadBlock);
            ret.initDate(root, pathData, index)
            return ret;
        }

        private function initDate(root:Sprite, pathData:cfg_path, index:Number):void
        {
            _id = pathData.roadblock_ids[index];
            _curPos.x = pathData.roadblock_points[2 * index];
            _curPos.y = pathData.roadblock_points[2 * index + 1];
            _oneDistance[0] = pathData.roadblock_distance[4 * index];
            _oneDistance[1] = pathData.roadblock_distance[4 * index + 1];
            _twoDistance[0] = pathData.roadblock_distance[4 * index + 2];
            _twoDistance[1] = pathData.roadblock_distance[4 * index + 3];
            if (!_ani)
            {
                _ani = new Image();
                root.addChild(_ani);
            }
            if (!_lineSprite)
            {
                _lineSprite = new Sprite();
                root.addChild(_lineSprite)
            }
            initRotation();
            if (GameConst.draw_collision_rect == true)
            {
                _lineSprite.visible = true;
            }
            _ani.skin = cfg_goods.instance(_id + "").icon;
            _width = cfg_goods.instance(_id + "").fight_length[0];
            _height = cfg_goods.instance(_id + "").fight_length[1];
            _ani.width = _width;
            _ani.height = _height;
            _ani.pivot(_width / 2, _height / 2);
            _ani.visible = true;
            _ani.zOrder = _depth;
            _colliRect.width = _width;
            _colliRect.height = _height;
            _isValid = true;
        }

        private function initRotation():void
        {
            var oneDown:Point = ZumaMap.instance.linePointOfDistance(_oneDistance[0]);
            var twoDown:Point = ZumaMap.instance.linePointOfDistance(_oneDistance[1]);
            _roration = GameTools.CalLineAngle(new Point(oneDown.x - twoDown.x, oneDown.y - twoDown.y), new Point(0, 0)) - 90;
            _ani.rotation = _roration;
        }


        override public function update(delta:Number):void
        {

        }

        override public function isValid():Boolean
        {
            return _isValid;
        }

        override public function destroy():void
        {
            if (isValid() == false)
            {
                return
            }
            _isValid = false;
            _ani.visible = false;
            _lineSprite.visible = false;
            CachePool.Cache("RoadBlock", null, RoadBlock);
        }

        public function screenResize():void
        {
            if (_ani.visible == false || !_curPos || isValid() == false)
            {
                return
            }
            _screenPos = CoordGm.instance.zumaTopoDesToScr(_curPos);
            _ani.pos(_screenPos.x, _screenPos.y);
            _colliRect.x = _ani.x - _width / 2;
            _colliRect.y = _ani.y - _height / 2;
            GameTools.drawCollision(_lineSprite, _colliRect);
        }

        public function getDepthByDistance(distance:Number):Number
        {
            if (distance >= _oneDistance[0] && distance <= _oneDistance[1])
            {
                return BallDepth.DOWN
            }

            if (distance >= _twoDistance[0] && distance <= _twoDistance[1])
            {
                return BallDepth.UP
            }
            return BallDepth.MIDDLE

        }
    }
}