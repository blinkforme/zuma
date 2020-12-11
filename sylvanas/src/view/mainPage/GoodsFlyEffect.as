package view.mainPage {
	
	import laya.display.Sprite;
	import manager.ConfigManager;
	import manager.GameConst;
	import laya.maths.Point;
	import manager.GameAnimation;
	import manager.AnimalManger;
	import manager.FishAniManager;
	import laya.ui.Image;
	import manager.GameTools;

	public class GoodsFlyEffect {

		public var _delay:Number;
        public var _startX:Number;
        public var _startY:Number;
        public var _endX:Number;
        public var _endY:Number;
        public var _goodsId:int;
        public var _image:Sprite;
        public var _bezierX:Number;
        public var _bezierY:Number;
        public var _bezierStartX:Number;
        public var _bezierStartY:Number;
        public var _bezierEndX:Number;
        public var _bezierEndY:Number;
        public var _bezierTotalTime:Number;
        public var _bezierUseTime:Number;
        public var _lineDelay:Number;
        public var _lineDeltaX:Number;
        public var _lineDeltaY:Number;
        public var _lineLeftTime:Number;
        public var _lineTotalTime:Number;
        public var _isAni:Boolean = false;
        public var _isOwn:Boolean = false;
        public var _lineSpeed:Number = 1000;
        public static var _aniCacheArray:Array;
        public static var _yinbiCacheArray:Array;
        public static var _iconCacheArray:Array;

		// 创建动画
		public static function Create(goodsId:int, startX:Number, startY:Number, endX:Number, endY:Number, delay:Number, parent:Sprite, isOwn:Boolean, rnd:Array):GoodsFlyEffect
        {
            var ret:GoodsFlyEffect;
            if (!_aniCacheArray)
            {
                _aniCacheArray = [];
                _iconCacheArray = [];
                _yinbiCacheArray = [];
            }
            var goodsIcon:String = ConfigManager.getConfValue("cfg_goods", goodsId, "waceIcon") as String;
            if (GameConst.currency_coin == goodsId || GameConst.currency_silver == goodsId)
            {
            	var cache:Array = _aniCacheArray;
                if (GameConst.currency_silver == goodsId)
                {
                    cache = _yinbiCacheArray;
                }

                if (cache.length > 0)
                {
                    for (var i:int = 0; i < cache.length; i++)
                    {
                        ret = cache[i] as GoodsFlyEffect;
                        if (ret._isOwn == isOwn)
                        {
                            cache.splice(i, 1);
                            ret.init(goodsId, startX, startY, endX, endY, delay, parent, isOwn, rnd);
                            break;
                        }
                        ret = null;
                    }
                }
                if (!ret)
                {
                    ret = new GoodsFlyEffect(goodsId, startX, startY, endX, endY, delay, parent, isOwn, rnd);
                }
            } else
            {
                if (_iconCacheArray.length > 0)
                {
                    ret = _iconCacheArray[0] as GoodsFlyEffect;
                    _iconCacheArray.splice(0, 1);
                    ret.init(goodsId, startX, startY, endX, endY, delay, parent, isOwn, rnd);
                } else
                {
                    ret = new GoodsFlyEffect(goodsId, startX, startY, endX, endY, delay, parent, isOwn, rnd);
                }
            }
            return ret;
        }

		// 动画初始化
		private static var _pointStart:Point = new Point();
		private static var _pointEnd:Point = new Point();
		public function init(goodsId:int, startX:Number, startY:Number, endX:Number, endY:Number, delay:Number, parent:Sprite, isOwn:Boolean, rnd:Array):void
        {
            _goodsId = goodsId;
            var goodsIcon:String = ConfigManager.getConfValue("cfg_goods", goodsId, "waceIcon") as String;
            if (!rnd)
            {
                rnd = new Array();
                for (var i:int = 0; i < 8; i++)
                {
                    rnd.push(Math.random());
                }
            }
            _isOwn = isOwn;
            if (!_image)
            {
                if (GameConst.currency_coin == goodsId ||
                        GameConst.currency_silver == goodsId)
                {
                    var aniName:String = "coin";
                    var ani:GameAnimation;
                    if (GameConst.currency_silver == goodsId)
                    {
                        aniName = "yinbi";
                    }
                    _isAni = true;
                    ani = FishAniManager.instance.load(aniName);
                    ani.outLoop = true;
                    _image = ani;
                    _image.pivot(ConfigManager.getConfValue("cfg_anicollision", aniName, "pivotX") as int,
                            ConfigManager.getConfValue("cfg_anicollision", aniName, "pivotY") as int);
                    ani.play(0, true);
                } else
                {
                    _image = new Image(goodsIcon);
                }
            } else
            {
                if (GameConst.currency_coin == goodsId ||
                        GameConst.currency_silver == goodsId)
                {
                    var aniTmp:GameAnimation;
                    aniTmp = _image as GameAnimation;
                    aniTmp.play(0, true);
                } else
                {
                    var tmpImage:Image = _image as Image;
                    tmpImage.skin = goodsIcon;
                }
            }

            parent.addChild(_image);
            _image.x = startX;
            _image.y = startY;
            _delay = delay;
            _startX = startX;
            _startY = startY;
            _bezierStartX = startX;
            _bezierStartY = startY;
            _endX = endX;
            _endY = endY;
            _image.visible = _delay <= 0;
            var minX:Number = 60;
            var deltaX:Number = 60;
            var minY:Number = 60;
            var deltaY:Number = 60;
            var rndX:Number;
            var rndY:Number;
            var rndIndex:int = 0;
            if (rnd[rndIndex++] < 0.5)
            {
                //左右random
                rndX = minX + rnd[rndIndex++] * deltaX;
                rndY = rnd[rndIndex++] * (minY + deltaY);
            } else
            {
                //上下random
                rndY = minY + rnd[rndIndex++] * deltaY;
                rndX = rnd[rndIndex++] * (minX + deltaX);
            }

            if (rnd[rndIndex++] < 0.5)
            {
                _bezierEndX = startX + rndX;
            } else
            {
                _bezierEndX = startX - rndX;
            }

            if (rnd[rndIndex++] < 0.5)
            {
                _bezierEndY = startY + rndY;
            } else
            {
                _bezierEndY = startY - rndY;
            }
            if (_bezierEndX < 0)
            {
                _bezierEndX = -_bezierEndX;
            } else if (_bezierEndX > Laya.stage.width)
            {
                _bezierEndX = startX + startX - _bezierEndX;
            }
            if (_bezierEndY < 0)
            {
                _bezierEndY = -_bezierEndY;
            } else if (_bezierEndY > Laya.stage.height)
            {
                _bezierEndY = startY + startY - _bezierEndY;
            }
            var angle:Number;
            var len:Number;
            var radian:Number;
            _bezierX = (startX + _bezierEndX) / 2;
            _bezierY = Math.min(startY, _bezierEndY) - 40 - 80 * rnd[rndIndex++];
            _bezierUseTime = 0;
            _bezierTotalTime = 0.2;
            _lineDelay = 0.5;
			_pointStart.x = _bezierEndX;
			_pointStart.y = _bezierEndY;
			_pointEnd.x = _endX;
			_pointEnd.y = _endY;
            len = GameTools.CalPointLen(_pointStart, _pointEnd); // (new Point(_bezierEndX, _bezierEndY), new Point(_endX, _endY));
            _lineLeftTime = len / _lineSpeed;
            _lineTotalTime = _lineLeftTime;
			
            angle = GameTools.CalLineAngle(_pointStart, _pointEnd); // (new Point(_bezierEndX, _bezierEndY), new Point(_endX, _endY));
            radian = angle * Math.PI / 180;
            _lineDeltaX = Math.cos(radian);
            _lineDeltaY = Math.sin(radian);
            _image.scale(1, 1);
        }

		public function GoodsFlyEffect(goodsId:int, startX:Number, startY:Number, endX:Number, endY:Number, delay:Number, parent:Sprite, isOwn:Boolean, rnd:Array)
        {
            init(goodsId, startX, startY, endX, endY, delay, parent, isOwn, rnd);
        }

		public function getEffectTime():Number
        {
            return _delay + _bezierTotalTime + _lineTotalTime + _lineDelay;
        }

		public function update(delta:Number):void
        {
            if (_image is GameAnimation)
            {
                var ani:GameAnimation = _image as GameAnimation;
                ani.outFrameLoop(Laya.timer.delta);
            }
            if (_delay > 0)
            {
                _delay -= delta;
                if (_delay <= 0)
                {
                    _image.visible = true;
                }
                return;
            }

            var pos_x:Number;
            var pos_y:Number;
            if (_bezierUseTime < _bezierTotalTime)
            {
                _bezierUseTime += delta;
                if (_bezierUseTime > _bezierTotalTime)
                {
                    _bezierUseTime = _bezierTotalTime
                }
                var t:Number = _bezierUseTime / _bezierTotalTime;
                var minusT:Number = 1 - t;
                pos_x = minusT * minusT * _bezierStartX + 2 * t * minusT * _bezierX + t * t * _bezierEndX;
                pos_y = minusT * minusT * _bezierStartY + 2 * t * minusT * _bezierY + t * t * _bezierEndY;
                _image.x = pos_x;
                _image.y = pos_y;

            } else
            {
                if (_lineDelay > 0)
                {
                    _lineDelay -= delta;
                    return;
                }
                _lineLeftTime -= delta;
                if (_lineLeftTime < 0)
                {
                    _lineLeftTime = 0;
                }
                _image.x = _image.x + _lineDeltaX * delta * _lineSpeed;
                _image.y = _image.y + _lineDeltaY * delta * _lineSpeed;
                //_image.scale(_lineLeftTime * 0.8 / _lineTotalTime + 0.2, _lineLeftTime * 0.8 / _lineTotalTime + 0.2);
                //_image.scale(_lineLeftTime * 1 / _lineTotalTime + 1, _lineLeftTime * 1 / _lineTotalTime + 1);
            }
        }

		public function destroy():void
        {
            //_image.removeSelf();
            _image.visible = false;
            if (GameConst.unused_remove_self)
            {
                _image.removeSelf();
            }
            if (_isAni)
            {
                var ani:GameAnimation;
                ani = _image as GameAnimation;
                ani.stop();
                if (_goodsId == GameConst.currency_coin)
                {
                    _aniCacheArray.push(this);
                } else
                {
                    _yinbiCacheArray.push(this);
                }
            } else
            {
                _iconCacheArray.push(this);
            }
        }

        public function isEnd():Boolean
        {
            return _lineLeftTime <= 0;
        }
	}
}