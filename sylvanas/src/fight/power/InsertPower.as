package fight.power
{
    import fight.zuma.Ball;
    import fight.FightChain;

    import laya.maths.Point;

    import manager.GameTools;

    public class InsertPower extends PowerBase
    {



        public function InsertPower(ball:Ball, chain:FightChain)
        {
            super(ball, chain);
        }

        public function moveBall(delta:Number):void
        {
            if (isValid)
            {
                var distance:Number = delta * ball.getInsertSpeed()

                var nowPoint:Point = ball.aniPoint()
                var targetPoint:Point = ball.targetPosition.point

                if (targetPoint)
                {
                    var remainDistance:Number = GameTools.CalPointLen(nowPoint, targetPoint)
                    if (distance >= remainDistance)
                    {
                        ball.moveTo(targetPoint)
                        ball.curPos = ball.targetPosition.copy()
                        ball.isOnLine = true

                        isValid = false
                    } else
                    {
                        var p:Point = new Point()
                        p.x = nowPoint.x + (targetPoint.x - nowPoint.x) * distance / remainDistance
                        p.y = nowPoint.y + (targetPoint.y - nowPoint.y) * distance / remainDistance
                        ball.moveTo(p)
                    }
                }

            }
        }

        public function execute(delta):void
        {
            moveBall(delta)
        }

        override public function destory():void
        {

        }


    }
}
