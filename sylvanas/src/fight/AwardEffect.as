package fight
{

    import laya.display.Sprite;
    import laya.maths.Point;
    import laya.ui.FontClip;
    import laya.ui.Image;

    import manager.ConfigManager;
    import manager.GameConst;
    import manager.GameSoundManager;
    import manager.GameTools;

    public class AwardEffect
    {
        private static var awardNumActionY:Array = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -6, -11, -18, -24, -30, -36, -42, -48, -54];
        private static var awardNumActiconScale:Array = [0.5, 0.7, 0.9, 1.1, 1.3, 1.5, 1.4, 1.3, 1.2, 1.1, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0];
        private static var awardNumActiconAlpha:Array = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 229 / 255, 204 / 255, 178 / 255, 153 / 255, 127 / 255, 102 / 255, 76 / 255, 51 / 255, 25 / 255];
        private var numFont:FontClip;
        private var originX:Number;
        private var originY:Number;
        private var numActionIndex:Number;
        private var _delay:Number;
        private var _delayIndex:int = 0;
        private static var _cacheArray:Array = null;
        private static var _cacheObject:Object = null;


        public static function create(value:int, pos:Point, fontType:Number, parent:Sprite, delay:Number, preLoad:Boolean = false):AwardEffect
        {
            if (!_cacheArray)
            {
                _cacheArray = [];
            }
            if (!_cacheObject)
            {
                _cacheObject = new Object();
            }
            var ret:AwardEffect;
            if (!preLoad && _cacheArray.length > 0)
            {
                ret = _cacheArray[0] as AwardEffect;
                ret.init(value, pos, fontType, parent, delay);
                _cacheArray.splice(0, 1);
            }
            else
            {
                ret = new AwardEffect(value, pos, fontType, parent, delay);
            }
            if (fontType == GameConst.font_type_own)
            {
                var soundPath:String = ConfigManager.getConfValue("cfg_global", 1, "get_coin_sound") as String;
                GameSoundManager.playSound(soundPath);
            }
            return ret;
        }

        public function destroy():void
        {
            //			if(numFont)
            //			{
            //				numFont.removeSelf();
            //				numFont = null;
            //			}
            numFont.visible = false;
            _cacheArray.push(this);
        }

        public function init(value:int, pos:Point, fontType:Number, parent:Sprite, delay:Number):void
        {

            var fontStr:String = "font/font_1.png";
			var fontSheet:String = "/.+-0123456789枚万亿";
			if(fontType == GameConst.font_type_own)
			{
			}
			else if(fontType == GameConst.font_type_other)
			{
				fontStr = "font/font_2.png";
				fontSheet = "/.+-0123456789枚万亿";
			}
			else if(fontType == GameConst.font_type_plot_type_battery_treat)
			{
				fontStr = "font/1.png";
				fontSheet = "+0123456789";
			}
			else if(fontType == GameConst.font_type_plot_type_battery)
			{
				fontStr = "font/2.png";
				fontSheet = "-0123456789";
			}
			else if(fontType == GameConst.font_type_shield_absorb)
			{
				fontStr = "font/4.png";
				fontSheet = "/.+-0123456789";
			}

            if (!numFont)
            {
                numFont = new FontClip(fontStr, fontSheet);
            }
            numFont.skin = fontStr;
			numFont.sheet = fontSheet;
			parent.addChild(numFont);
            _delay = delay;
            _delayIndex = 0;



			if(fontType == GameConst.font_type_plot_type_fish ||
				fontType == GameConst.font_type_shield_absorb)
			{
				numFont.value = "" + value;
			}
			else if(value >= 0)
			{
                if(fontType == GameConst.font_type_plot_type_battery)
                {
                    numFont.value = "-" + value;
                }else
                {
                    numFont.value = "+" + value;
                }
			}
			else
			{
				numFont.value = "" + value;
			}

            originX = pos.x;
            originY = pos.y;
            if (originX < 40)
            {
                originX = 40;
            }
            if (originX > Laya.stage.width - 40)
            {
                originX = Laya.stage.width - 40;
            }
            if (originY < 50)
            {
                originY = 50;
            }
            if (originY > Laya.stage.height - 10)
            {
                originY = Laya.stage.height - 10;
            }
            numActionIndex = 0;
            numFont.pos(originX, originY);
            numFont.anchorX = 0.5;
            numFont.anchorY = 0.5;
            numFont.visible = _delay <= 0;
			var tmpChild:Image = numFont.getChildAt(0) as Image;
			if(fontType == GameConst.font_type_shield_absorb)
			{


				if(!tmpChild)
				{
					tmpChild = new Image();
					tmpChild.loadImage("font/font_xishou.png");

					numFont.addChild(tmpChild);
				}
				tmpChild.visible = true;
//				tmpChild.x = 0;
				tmpChild.anchorX = 1;
				tmpChild.anchorY = 0;
				tmpChild.y = -5;//(numFont.height - tmpChild.height) / 2;
				numFont.x = numFont.x + tmpChild.width / 2
				originX = numFont.x;
				originY = numFont.y;


			}
			else
			{
				if(tmpChild)
				{
					tmpChild.visible = false;
				}
			}

            updateNumberPos();
        }
		private static var _count:Number = 0;
        public function AwardEffect(value:int, pos:Point, fontType:Number, parent:Sprite, delay:Number)
        {
			if(GameConst.cache_test_open)
			{
				_count++;
				trace("AwardEffect count", _count);
			}
            init(value, pos, fontType, parent, delay);
        }

        private function updateNumberPos():void
        {
            if (numFont && (numActionIndex < awardNumActionY.length))
            {
                numFont.pos(originX, originY + awardNumActionY[numActionIndex]);
                numFont.scale(awardNumActiconScale[numActionIndex] * GameTools.getDesignScale(),
                        awardNumActiconScale[numActionIndex] * GameTools.getDesignScale());
                numFont.alpha = awardNumActiconAlpha[numActionIndex];
            }
        }

        public function isValid():Boolean
        {
            return numActionIndex < awardNumActionY.length;
        }

        public function update(delta:Number):void
        {
            if (_delay > 0)
            {
                _delay -= delta;
                if (_delay <= 0)
                {
                    numFont.visible = true;
                }
                return;
            }

            _delayIndex += 1;
            if (_delayIndex >= 3)
            {
                numActionIndex += 1;
                _delayIndex = 0;
            }
            updateNumberPos();
        }

    }
}
