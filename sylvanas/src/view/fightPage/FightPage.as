package view.fightPage
{
    import view.mainPage.*;
    import enums.UiType;

    import manager.BaseView;
    import manager.PanelVo;

    public class FightPage extends BaseView implements PanelVo
    {

        public function FightPage()
        {
            super();
        }

        public function get pngNum():int
        {
            return 0;
        }

        public function startGame(parm:Object = null, name:String = null):void
        {
            creatPanel(FightPageView, parm, name);

        }

        public function get uiType():String
        {
            return UiType.UI_TYPE_FIGHT_PAGE;
        }
    }
}
