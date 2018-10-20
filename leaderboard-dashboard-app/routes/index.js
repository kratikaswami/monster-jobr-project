module.exports = {
    getHomePage: (req, res) => {
        const userPointsQuery = "select  u.name,  p.points, p.reason from points p inner join user u on p.user_id = u.id";
        const userLeaderBoardQuery = "select u.id, u.name, p.points from user u inner join points p on u.id = p.user_id order by p.points desc";
        const teamLeaderBoardQuery = "select t.id, t.name, sum(p.points) as total_points from team t inner join user u on t.id = u.team_id inner join points p on u.id = p.user_id group by t.id order by total_points desc";
        const teamPercentLeaderBoardQuery = "select t.id, t.name, (sum(p.points)/(select sum(points) from points) * 100) as percent_points from team t inner join user u on t.id = u.team_id inner join points p on u.id = p.user_id group by t.id order by percent_points desc";
        var userPoints = [];
        var userLeaderBoard = [];
        var teamLeaderBoard = [];
        var teamPercentLeaderBoard = [];

        db.query(userPointsQuery, function(err, result) {
            userPoints = result;
            if (err) {
                res.redirect('/');
            }
            db.query(userLeaderBoardQuery, (err, result) => {
                userLeaderBoard = result;
                if (err) {
                    res.redirect('/');
                }

                db.query(teamLeaderBoardQuery, (err, result) => {
                    teamLeaderBoard = result;
                    if (err) {
                        res.redirect('/');
                    }

                    db.query(teamPercentLeaderBoardQuery, (err, result) => {
                        console.log(result);
                        teamPercentLeaderBoard = result;
                        if (err) {
                            res.redirect('/');
                        }

                        res.render('index.ejs', {
                            title: "Welcome to Players and Teams Dashboard",
                            userPoints: userPoints,
                            userLeaderBoard: userLeaderBoard,
                            teamLeaderBoard: teamLeaderBoard,
                            teamPercentLeaderBoard: teamPercentLeaderBoard,
                        });
                    });
                });
            });
        });
    }
};