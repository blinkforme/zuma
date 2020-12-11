package manager
{
    import laya.display.Sprite;
    import laya.maths.Point;
    import laya.maths.Rectangle;

    public class GameTools
    {

        private static var _designScale:Number = 1;

        public static function screenResize():void
        {

            _designScale = Laya.stage.width / GameConst.design_width;

            if (_designScale > Laya.stage.height / GameConst.design_height)
            {
                _designScale = Laya.stage.height / GameConst.design_height;
            }
        }


        public static function getDesignScale():Number
        {
            return _designScale;
        }


        private static var _acosAngleDic:Array = [];
        private static var _sinAngleDic:Array = [];
        private static var _cosAngleDic:Array = [];

        public static function CalSinBySheet(angle:Number):Number
        {
            if (angle < 0)
            {
                angle += 360;
            } else if (angle >= 360)
            {
                angle -= 360;
            }
            if (!GameConst.GameToosCalBySheet)
            {
                var radian:Number = angle * 3.14159 / 180;
                return Math.sin(radian);
            }

            angle = Math.ceil(angle * 100);
            return _sinAngleDic[angle];
        }

        public static function CalCosBySheet(angle:Number):Number
        {
            if (angle < 0)
            {
                angle += 360;
            } else if (angle >= 360)
            {
                angle -= 360;
            }
            if (!GameConst.GameToosCalBySheet)
            {
                var radian:Number = angle * 3.14159 / 180;
                return Math.cos(radian);
            }

            angle = Math.ceil(angle * 100);
            return _cosAngleDic[angle];
        }


        private static var _PiToAngle:Number = 180 / Math.PI;

        public static function CalAngleByAcos(acos:Number):Number
        {
            if (!GameConst.GameToosCalBySheet)
            {
                return Math.acos(acos) * _PiToAngle
            }
            var tmp:int = Math.floor(acos * 10000 + 10000);
            return _acosAngleDic[tmp];
        }


        public static function CalSqrtBySheet(deltaX:Number, deltaY:Number):Number
        {
            var powLen:Number = deltaX * deltaX + deltaY * deltaY;
            return Math.sqrt(powLen);
        }


        public static function CalLineAngle(startPos:Point, endPos:Point):Number
        {


            var deltaX:Number = endPos.x - startPos.x;
            var deltaY:Number = endPos.y - startPos.y;
            if ((deltaY === 0) && (deltaX < 0))
            {
                return 180;
            }

            var length:Number = CalSqrtBySheet(deltaX, deltaY);//Math.sqrt(deltaX * deltaX + deltaY * deltaY);//CalSqrtBySheet(deltaX, deltaY);
            if (length <= 0)
            {
                return 0;
            }
            var cos:Number = deltaX / length;

            if (cos < -1)
            {
                cos = -1;
            } else if (cos > 1)
            {
                cos = 1;
            }
            var angle:Number = CalAngleByAcos(cos);

            if (deltaY < 0)
            {
                angle = 360 - angle;
            }

            return angle;
        }


        public static function CalPointLen(startPos:Point, endPos:Point):Number
        {
            return CalSqrtBySheet(endPos.x - startPos.x, endPos.y - startPos.y);
        }


        public static function now():Number
        {
            return __JS__('Date.now()');
        }


        public static function notch():String
        {
            {
                var _notch:String = 'left';
                var tmpwindow:* = __JS__('window');
                if ('orientation' in tmpwindow)
                {
                    // Mobile
                    if (tmpwindow.orientation == 90)
                    {
                        _notch = 'left';
                    } else if (tmpwindow.orientation == -90)
                    {
                        _notch = 'right';
                    }
                } else if ('orientation' in tmpwindow.screen)
                {
                    // Webkit
                    if (tmpwindow.screen.orientation.type === 'landscape-primary')
                    {
                        _notch = 'left';
                    } else if (tmpwindow.screen.orientation.type === 'landscape-secondary')
                    {
                        _notch = 'right';
                    }
                } else if ('mozOrientation' in tmpwindow.screen)
                {
                    // Firefox
                    if (tmpwindow.screen.mozOrientation === 'landscape-primary')
                    {
                        _notch = 'left';
                    } else if (tmpwindow.screen.mozOrientation === 'landscape-secondary')
                    {
                        _notch = 'right';
                    }
                }
                return _notch;
            }
            return "left";
        }

        public static function drawCollision(lineSprite:Sprite, _colliRect:Rectangle):void
        {
            if (!GameConst.draw_collision_rect)
            {
                return;
            }
            var color:String = "#ff0000";
            lineSprite.graphics.clear();
            lineSprite.graphics.drawLine(_colliRect.x, _colliRect.y, _colliRect.x + _colliRect.width, _colliRect.y, color, 4);
            lineSprite.graphics.drawLine(_colliRect.x, _colliRect.y, _colliRect.x, _colliRect.y + _colliRect.height, color, 4);
            lineSprite.graphics.drawLine(_colliRect.x + _colliRect.width, _colliRect.y, _colliRect.x + _colliRect.width, _colliRect.y + _colliRect.height, color, 4);
            lineSprite.graphics.drawLine(_colliRect.x, _colliRect.y + _colliRect.height, _colliRect.x + _colliRect.width, _colliRect.y + _colliRect.height, color, 4);
        }

        public static function drawCd(parent:Sprite , mask:Sprite , value:Number):void
        {
            value = Clamp(value , 0 , 1);
            mask.graphics.clear();
            mask.graphics.drawPie(parent.width * 0.5 , parent.height * 0.5 , parent.width * 0.5 , -90 + (1-value) * 360 , 360 - 90 , "#000000" , "#000000" , 1);
        }

        public static function Clamp(value:Number , min:Number , max:Number):Number
        {
            if(value < min)
            {
                value = min;
            }
            if(value > max)
            {
                value = max;
            }
            return value;
        }

    }
}
