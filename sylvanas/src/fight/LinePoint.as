package fight
{
    import laya.d3.math.Vector2;
    import laya.maths.Point;

    import manager.GameTools;

    public class LinePoint
    {
        private var _point:Point
        private var _no:Number

        private var _startDistance:Number;
        private var _nVector:Vector2 = new Vector2();

        private var _line:Line;

        public function LinePoint(line:Line, point:Point, no:Number)
        {
            _no = no;
            _line = line;
            _point = point
        }


        public function prevLinePoint():LinePoint
        {
            if (isFirstPoint())
            {
                return null
            } else
            {
                return _line.points[_no - 1]
            }
        }

        public function nextLinePoint():LinePoint
        {
            if (isLastPoint())
            {
                return null
            } else
            {
                return _line.points[_no + 1]
            }
        }

        public function init():void
        {
            if (isFirstPoint())
            {
                startDistance = 0
            } else
            {
                var prevLinePoint:LinePoint = line.points[_no - 1]
                startDistance = prevLinePoint.startDistance + GameTools.CalPointLen(prevLinePoint.point, _point)
            }

            if (isLastPoint())
            {
                _nVector = null
            } else
            {
                var nextPoint:LinePoint = line.points[_no + 1]
                var tmpVector:Vector2 = new Vector2(nextPoint.point.x - _point.x, nextPoint.point.y - _point.y)
                Vector2.normalize(tmpVector, _nVector)
            }
        }


        public function isFirstPoint():Boolean
        {
            return _no == 0
        }

        public function isLastPoint():Boolean
        {
            return _line.points.length == _no + 1
        }

        public function get line():Line
        {
            return _line;
        }

        public function set line(value:Line):void
        {
            _line = value;
        }

        public function get nVector():Vector2
        {
            return _nVector;
        }

        public function set nVector(value:Vector2):void
        {
            _nVector = value;
        }

        public function isInThisPoint(value:Number):Boolean
        {
            return value >= startDistance && value < endDistance
        }

        public function get startDistance():Number
        {
            return _startDistance;
        }

        public function set startDistance(value:Number):void
        {
            _startDistance = value;
        }

        public function get endDistance():Number
        {
            if (isLastPoint())
            {
                return startDistance
            } else
            {
                var nextPoint:LinePoint = nextLinePoint()
                return nextPoint.startDistance
            }
        }


        public function get no():Number
        {
            return _no;
        }


        public function get point():Point
        {
            return _point;
        }

        public function set point(value:Point):void
        {
            _point = value;
        }
    }
}