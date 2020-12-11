package view.award
{
import view.account.*;
    import enums.UiType;

    import manager.BaseView;
    import manager.PanelVo;

    public class Award extends BaseView implements PanelVo
    {
        public function Award()
        {
            super();
        }

        public function get pngNum():int
        {
            return 0;
        }

        public function startGame(parm:Object = null, name:String = null):void
        {
            creatPanel(AwardView, parm, name);

        }

        public function get uiType():String
        {
            return UiType.UI_TYPE_ERROR_TIP;
        }
    }
}