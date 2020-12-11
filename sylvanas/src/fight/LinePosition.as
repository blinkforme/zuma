package fight
{
    import laya.maths.Point;

    public class LinePosition
    {

        private var _curLinePoint:LinePoint = null

        private var _curDistance:Number = 0

        private var _designPoint:Point = new Point()


        public var _line:Line

        public function LinePosition(curLinePoint:LinePoint, distance:Number, line:Line)
        {
            _line = line
            _curLinePoint = curLinePoint
            curDistance = distance
        }

        public function copy():LinePosition
        {
            var p:LinePosition = new LinePosition(_curLinePoint, _curDistance, _line)
            return p
        }

        public function move(distance:Number):LinePosition
        {
            curDistance = curDistance + distance
            return this
        }


        public function get point():Point
        {
            return _designPoint
        }


        public function get curLinePoint():LinePoint
        {
            return _curLinePoint;
        }


        public function get curDistance():Number
        {
            return _curDistance;
        }

        private function _calcDesignPoint():void
        {
            var overDistance:Number = _curDistance - _curLinePoint.startDistance
            _designPoint.x = _curLinePoint.point.x + _curLinePoint.nVector.x * overDistance
            _designPoint.y = _curLinePoint.point.y + _curLinePoint.nVector.y * overDistance
        }

        public function set curDistance(value:Number):void
        {
            if (value == _curDistance)
            {
                return
            }


            if (value >= _line.tailPoint().endDistance)
            {
                value = _line.tailPoint().endDistance
                _curLinePoint = _line.tailPoint()
                _curDistance = value
                _designPoint.x = _curLinePoint.point.x
                _designPoint.y = _curLinePoint.point.y
                return
            }

            if (value <= 0)
            {
                _curLinePoint = _line.headPoint
                _curDistance = 0
                _designPoint.x = _curLinePoint.point.x
                _designPoint.y = _curLinePoint.point.y
                return
            }


            if (_curLinePoint.isInThisPoint(value))
            {
                _curDistance = value
                _calcDesignPoint()
            } else
            {
                if (value > _curDistance)
                {
                    var nextLinePoint:LinePoint = _curLinePoint.nextLinePoint()
                    while (nextLinePoint)
                    {
                        if (nextLinePoint.isInThisPoint(value))
                        {
                            _curLinePoint = nextLinePoint
                            _curDistance = value
                            _calcDesignPoint()
                            return
                        } else
                        {
                            nextLinePoint = nextLinePoint.nextLinePoint()
                        }
                    }
                } else
                {
                    var prevLinePoint:LinePoint = _curLinePoint.prevLinePoint()
                    while (prevLinePoint)
                    {
                        if (prevLinePoint.isInThisPoint(value))
                        {
                            _curLinePoint = prevLinePoint
                            _curDistance = value
                            _calcDesignPoint()
                            return
                        } else
                        {
                            prevLinePoint = prevLinePoint.prevLinePoint()
                        }
                    }
                }
            }

        }
    }
}