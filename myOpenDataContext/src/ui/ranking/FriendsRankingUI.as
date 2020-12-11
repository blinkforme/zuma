/**This class is automatically generated by LayaAirIDE, please do not make any modifications. */
package ui.ranking {
	import laya.ui.*;
	import laya.display.*;

	public class FriendsRankingUI extends Scene {
		public var rankList:List;
		public var prevPage:Image;
		public var nextPage:Image;
		public var currentPage:Label;

		public static var uiView:Object =/*[STATIC SAFE]*/{"type":"Scene","props":{"width":440,"height":557},"compId":2,"child":[{"type":"List","props":{"y":24,"x":24,"width":391,"visible":false,"var":"rankList","top":41,"spaceY":0,"height":509,"centerX":0},"compId":11,"child":[{"type":"Box","props":{"y":0,"x":0,"width":388,"renderType":"render","height":73},"compId":6,"child":[{"type":"Image","props":{"y":0,"x":0,"width":385,"skin":"ui/friendsRanking/btn_enemy.png","sizeGrid":"10,10,10,10","height":80},"compId":10},{"type":"Image","props":{"x":41,"skin":"ui/friendsRanking/rank1.png","scaleY":0.5,"scaleX":0.5,"name":"rankImg","centerY":1,"anchorY":0.5,"anchorX":0.5},"compId":19},{"type":"Label","props":{"x":10,"width":60,"valign":"top","text":"1","strokeColor":"#bf6710","stroke":2,"overflow":"hidden","name":"rank","height":51,"fontSize":40,"font":"Arial","color":"#ffeda0","centerY":1,"bold":true,"align":"center"},"compId":12},{"type":"Image","props":{"y":1,"x":91,"skin":"ui/friendsRanking/img_iconbottom.png","scaleY":0.6,"scaleX":0.6},"compId":21},{"type":"Image","props":{"x":97,"width":60,"name":"avatarUrl","height":60,"centerY":0},"compId":7},{"type":"Label","props":{"x":169,"width":102,"text":"昵称","overflow":"scroll","name":"nickname","height":24,"fontSize":18,"font":"Microsoft YaHei","color":"#ab7437","centerY":0,"bold":true,"align":"center"},"compId":8},{"type":"Image","props":{"y":9,"x":268,"skin":"ui/friendsRanking/img_friends_levelbottom.png","scaleY":0.7,"scaleX":0.7},"compId":20},{"type":"Label","props":{"width":75,"valign":"middle","text":"关卡","strokeColor":"#d45000","stroke":2,"right":37,"name":"score","height":27,"fontSize":18,"color":"#fff8f6","centerY":-1,"bold":true,"align":"right"},"compId":9}]}]},{"type":"Box","props":{"width":300,"visible":false,"centerX":461,"bottom":394},"compId":15,"child":[{"type":"Image","props":{"var":"prevPage","skin":"ui/friendsRanking/friendRank_close.png","left":0,"centerY":0},"compId":16},{"type":"Image","props":{"var":"nextPage","skin":"ui/friendsRanking/friendRank_open.png","right":0,"centerY":0},"compId":17},{"type":"Label","props":{"width":100,"var":"currentPage","valign":"middle","text":"1/5","fontSize":28,"font":"Arial","color":"#fff","centerY":0,"centerX":0,"align":"center"},"compId":18}]}],"loadList":["ui/friendsRanking/btn_enemy.png","ui/friendsRanking/rank1.png","ui/friendsRanking/img_iconbottom.png","ui/friendsRanking/img_friends_levelbottom.png","ui/friendsRanking/friendRank_close.png","ui/friendsRanking/friendRank_open.png"],"loadList3D":[]};
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);

		}

	}
}