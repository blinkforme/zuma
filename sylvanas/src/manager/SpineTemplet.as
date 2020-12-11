package manager
{
    import conf.cfg_anicollision;

    import laya.display.Sprite;
    import laya.events.Event;
    import laya.utils.Handler;

    public class SpineTemplet extends Sprite
    {
        private var _aniName:* = 0;
        private var _path:String;
        private var _parent:Sprite;
        private var _mFactory:GameTemplet;
        private var _sketleton:GameSkeleton = null;
        private var _isLoad:Boolean;
        private var _isLoop:Boolean = true;
        private var _x:Number = 0;
        private var _y:Number = 0;
        private var _scaleX:Number = 1;
        private var _scaleY:Number = 1;
        private var _pivotX:Number = 0;
        private var _pivotY:Number = 0;
        private var _speed:Number = 1;
        private var _spineName:String;
        private var _isComplete:Boolean;
        private var _startTime:Number = 0;
        private var _handler:Handler = null;
        private var _outLoop:Boolean = false;
        private static var _spineTempletCache:Object = null;

        public function SpineTemplet(spineName:String, loopOut:Boolean = false)
        {
            if (!_spineTempletCache)
            {
                _spineTempletCache = new Object();
            }
            _outLoop = loopOut;
            var cfg_ani:cfg_anicollision = cfg_anicollision.instance(spineName);
            _pivotX = cfg_ani.pivotX;
            _pivotY = cfg_ani.pivotY;
            _scaleX = cfg_ani.scale;
            _scaleY = cfg_ani.scale;
            _spineName = spineName;
            _path = cfg_ani.spinePath;
            _speed = cfg_ani.aniSpeed;
            if (_spineTempletCache[_path])
            {
                _mFactory = _spineTempletCache[_path] as GameTemplet;
                parseComplete();
            }
            else
            {
                _mFactory = new GameTemplet();
                _mFactory.on(Event.COMPLETE, this, parseComplete);
                _mFactory.loadAni(_path);
            }

        }
		
		public function getPath():String
		{
			return _path;
		}
		
        public static function addFactoryCache(factory:GameTemplet, path:String):void
        {
            if (!_spineTempletCache)
            {
                _spineTempletCache = new Object();
            }
            _spineTempletCache[path] = factory;
        }

        public static function isPathCache(path:String):Boolean
        {
            if (_spineTempletCache)
            {
                return _spineTempletCache[path];
            }
            return false;
        }

        public function getSpineName():String
        {
            return _spineName;
        }

        public function get total():Number
        {
            return null;
        }

        private function parseComplete():void
        {
            if (!_spineTempletCache[_path])
            {
                _spineTempletCache[_path] = _mFactory
            }
            Laya.loader.clearRes(_path, false);
            _sketleton = _mFactory.buildArmature(0);
            _sketleton.name = _spineName;
            _sketleton.showSkinByIndex(1);
            if (_outLoop)
            {
                _sketleton.outLoop = true;
            }
            this.addChild(_sketleton);
            play(_aniName, _isLoop, _handler, _startTime);
            setPos(_x, _y);
            setPivot(_pivotX, _pivotY);
            _sketleton.scale(_scaleX, _scaleY);
        }

        public function play(aniName:*, isLoop:Boolean = false, handler:Handler = null, start:Number = 0):void
        {
            _handler = handler;
            _aniName = aniName;
            _isLoop = isLoop;
            _startTime = start;
            if (_sketleton != null)
            {
//                if (aniName == 1)  //1是标准速率
                    _sketleton.playbackRate(_speed);
                _sketleton.play(aniName, isLoop, true, _startTime);
                _sketleton.on(Event.STOPPED, this, complete, [handler]);
            }
        }

        public function set playBackRate(value:Number):void
        {
            if (_sketleton)
            {
                _sketleton.playbackRate(value);
            }
        }

        public function outUpdate():void
        {
            if (_outLoop && _sketleton && _sketleton.visible)
            {
                _sketleton.outUpdate();
            }
        }

        private function complete(handler:Handler):void
        {
            if (handler != null)
            {

                handler.run();
            }

        }


        public function isPlaying():Boolean
        {
            if (_sketleton)
            {
                //				if(sketleton.player.currentAnimationClipIndex >= 0)
                //				{
                //					
                //					return sketleton.index < sketleton.total;
                //				}
                return _sketleton.player.currentAnimationClipIndex >= 0;
            }
            return true;
        }

        public function stop():void
        {
            if (_sketleton)
            {
                _sketleton.stop();
            }
        }

        public function setFilters(filters:Array):void
        {
            if (_sketleton)
            {
                _sketleton.filters = filters;
            }
        }

        public function paused():void
        {
            if (_sketleton)
            {
                _sketleton.paused();
            }
        }

        public function resume():void
        {
            if (_sketleton)
            {
                _sketleton.resume();
            }
        }

        public function setPos(x:Number, y:Number):void
        {
            _x = x;
            _y = y;
            if (_sketleton != null)
            {

                _sketleton.x = _x;
                _sketleton.y = _y;
            }
        }

        public function setScale(x:Number, y:Number):void
        {
            _scaleX = x;
            _scaleY = y;
            if (null != _sketleton)
            {
                _sketleton.scale(x, y);
            }
        }

		
		
        public function get spineWidth():Number
        {
            if (_sketleton != null)
            {
                return _sketleton.width;
            } else
            {
                return 0;
            }
        }

        public function get spineHeight():Number
        {
            if (_sketleton != null)
            {
                return _sketleton.height;
            } else
            {
                return 0;
            }
        }

        public function setPivot(pivotX:Number, pivotY:Number):void
        {
            _pivotX = pivotX;
            _pivotY = pivotY;
            if (_sketleton != null)
            {
                _sketleton.pivotX = pivotX;
                _sketleton.pivotY = pivotY;
            }
        }


    }
}
