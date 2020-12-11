package view
{
    import laya.utils.Browser;
    import laya.utils.Handler;
    import laya.display.Text;
    import laya.ui.Image;
    import laya.ui.Label;
    import laya.events.Event;

    import ui.ranking.FriendsRankingUI;

    public class FriendsRanking extends FriendsRankingUI
    {
        public function FriendsRanking()
        {

        }

        /**获取好友排行榜时的key */
        private var _key:String = '';
        /**获取到的微信 */
        private var wx:*;
        /**初始化的list数据 */
        private var arr:Array = [];
        // 总页数
        private var totalPage:int = 1;
        // 当前页
        private var curPage:int = 0;

        /**
         * 初始化
         */
        public function init():void
        {
            //将此场景加到舞台上
            Laya.stage.addChild(this);
            //获取wx
            wx = Browser.window.wx;
            if (Browser.onMiniGame)
            {
                //接受来自主域的信息
                wx.onMessage(recevieData.bind(this));
                // 直接展示数据
                // getFriendData();
            }
            rankList.vScrollBarSkin = "";
            // 渲染排行榜
            rankList.renderHandler = new Handler(this, renderRank);
            // 点击切换页面
            prevPage.on(Event.CLICK, this, goPrevPage);
            nextPage.on(Event.CLICK, this, goNextPage);
        }

        // 前一页
        private function goPrevPage():void
        {
            curPage--;
            if (curPage >= 0)
            {
                rankList.array = arr;
                rankList.page = curPage;
                currentPage.text = (curPage + 1) + '/' + totalPage;
            } else
            {
                curPage = 0;
            }
        }

        // 后一页
        private function goNextPage():void
        {
            curPage++;
            if (curPage <= totalPage - 1)
            {
                rankList.array = arr;
                rankList.page = curPage;
                currentPage.text = (curPage + 1) + '/' + totalPage;
            } else
            {
                curPage = totalPage - 1;
            }
        }

        // 渲染排行榜
        private function renderRank(cell, index):void
        {
            var rankInfo:Object = cell.dataSource;
            var rank:Label = cell.getChildByName('rank') as Label;
            var rankImg:Image = cell.getChildByName('rankImg') as Image;
            var avatarUrl:Image = cell.getChildByName('avatarUrl') as Image;
            var nickname:Label = cell.getChildByName("nickname") as Label;
            var score:Label = cell.getChildByName("score") as Label;
            if (index === 0)
            {
                // 第一名
                rank.visible = false;
                rankImg.visible = true;
                rankImg.skin = 'ui/friendsRanking/rank1.png';
            } else if (index === 1)
            {
                // 第二名
                rank.visible = false;
                rankImg.visible = true;
                rankImg.skin = 'ui/friendsRanking/rank2.png';
            } else if (index === 2)
            {
                // 第三名
                rank.visible = false;
                rankImg.visible = true;
                rankImg.skin = 'ui/friendsRanking/rank3.png';
            } else
            {
                rank.visible = true;
                rankImg.visible = false;
            }
            rank.text = index + 1;
            avatarUrl.skin = rankInfo.avatarUrl;
            nickname.text = rankInfo.nickname;
            score.text = rankInfo.score + "关";
        }

        /**
         * 获取好友排行
         */
        private function getFriendData():void
        {
            wx.getFriendCloudStorage({
                keyList: [_key],
                success: function (res):void
                {
                    //关于拿到的数据详细情况可以产看微信文档
                    //https://developers.weixin.qq.com/minigame/dev/api/UserGameData.html
                    var listData:*;
                    var obj:*;
                    var kv:*;
                    arr = []; // 重新获取数据
                    console.log('-----------------getFriendCloudStorage------------');
                    if (res.data)
                    {
                        for (var i:int = 0; i < res.data.length; i++)
                        {
                            obj = res.data[i];
                            if (!(obj.KVDataList.length))
                                continue
                            //拉取数据是，使用了多少个key- KVDataList的数组就有多少
                            //更详细的KVData可以查看微信文档:https://developers.weixin.qq.com/minigame/dev/api/KVData.html
                            kv = obj.KVDataList[0];
                            if (kv.key != _key)
                                continue
                            kv = JSON.parse(kv.value)
                            listData = {};
                            listData.avatarUrl = obj.avatarUrl;
                            listData.nickname = obj.nickname;
                            listData.openid = obj.openid;
                            listData.score = kv.wxgame.score;
                            listData.update_time = kv.wxgame.update_time;
                            arr.push(listData);
                        }
                        //根据RankValue排序
                        arr = arr.sort(function (a, b):int
                        {
                            return b.score - a.score;
                        });
                        //增加一个用于查看的index排名
                        for (i = 0; i < arr.length; i++)
                        {
                            arr[i].index = i + 1;
                        }
                        arr = arr.splice(0, 100); // 取前100名
                        console.log(arr);
                        //设置数组
                        setlist(arr);
                    }
                }
                , fail: function (data):void
                {
                    console.log('------------------获取托管数据失败--------------------');
                    console.log(data);
                }
            });
        }

        /**
         * 接收信息
         * @param message 收到的主域传过来的信息
         */
        private function recevieData(message):void
        {
            var type:String = message.type;
            switch (type)
            {
                case 2:
                    // 好友列表
                    _key = 'score';
                    getFriendData();
                default:
                    break;
            }
        }

        /**
         * 上报自己的数据
         * @param data 上报数据
         */
        private function setSelfData(data:String):void
        {
            var kvDataList:Array = [];
            var obj:Object = {};
            obj.wxgame = {};
            obj.wxgame.value1 = data;
            obj.wxgame.update_time = Browser.now();
            kvDataList.push({"key": _key, "value": JSON.stringify(obj)});
            wx.setUserCloudStorage({
                KVDataList: kvDataList,
                success: function (e):void
                {
                    console.log('-----success:' + JSON.stringify(e));
                },
                fail: function (e):void
                {
                    console.log('-----fail:' + JSON.stringify(e));
                },
                complete: function (e):void
                {
                    console.log('-----complete:' + JSON.stringify(e));
                }
            });
        }

        /**
         * 设置list arr
         * @param arr 赋值用的arr
         */
        private function setlist(arr):void
        {
            curPage = 0;
            totalPage = Math.ceil(arr.length / 5);
            rankList.array = arr;
            rankList.page = curPage;
            rankList.totalPage = totalPage;
            rankList.visible = true;
            currentPage.text = (curPage + 1) + '/' + totalPage;
        }
    }
}