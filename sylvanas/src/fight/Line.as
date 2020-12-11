package fight
{
    import laya.d3.math.Vector2;

    public class Line
    {

        private var _points:Array = []
        //总长度
        private var _totalDistance:Number = 0

        public function Line()
        {
        }

        public static function create(points:Array):Line
        {
            var line:Line = new Line()
            line.init(points)
            return line
        }

        public function get headPoint():LinePoint
        {
            return points[0]
        }

        public function tailPoint():LinePoint
        {
            return _points[_points.length - 1]
        }

        public function initPoints():void
        {
            for (var i:Number = 0; i < _points.length; i++)
            {
                var point:LinePoint = _points[i]
                point.init()
            }
            //            console.log("_points", _points)
        }

        public function init(pointsArr:Array):void
        {
            for (var i:Number = 0; i < pointsArr.length; i++)
            {
                _points.push(new LinePoint(this, pointsArr[i], i))
            }
            initPoints()
        }


        public function get totalDistance():Number
        {
            return _totalDistance;
        }


        public function get points():Array
        {
            return _points;
        }

        public function startVector():Vector2
        {
            return _points[0].nVector
        }

        public function endVector():Vector2
        {
            return _points[_points.length - 2].nVector
        }


    }
}