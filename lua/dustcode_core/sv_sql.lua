do

if _DUSTCODE_DONATE.SqlInitialized then return end
_DUSTCODE_DONATE.Database = {}

local IsMysql = false

if (_DUSTCODE_DONATE.DataSaveType == 'mysqloo') then
	require('mysqloo') 
	IsMysql = true

	_DUSTCODE_DONATE.Database = mysqloo.connect(_DUSTCODE_DONATE.MySql.host, _DUSTCODE_DONATE.MySql.username, _DUSTCODE_DONATE.MySql.password, _DUSTCODE_DONATE.MySql.db_name, _DUSTCODE_DONATE.MySql.db_port)
	_DUSTCODE_DONATE.Database:setAutoReconnect(_DUSTCODE_DONATE.MySql.auto_reconnect)

	function _DUSTCODE_DONATE.Database:onConnected()
		_DUSTCODE_DONATE:Log("Connecting to DATABASE is successfully! ".._DUSTCODE_DONATE.MySql.host.."@".._DUSTCODE_DONATE.MySql.db_name, Color(0,255,0))
	end
	
	function _DUSTCODE_DONATE.Database:onConnectionFailed(error)
		_DUSTCODE_DONATE:Log(error, Color(255,0,0))
	end

	_DUSTCODE_DONATE.Database:connect()
elseif (_DUSTCODE_DONATE.DataSaveType == 'sqlite') then
	_DUSTCODE_DONATE.Database.query = sql.Query

	_DUSTCODE_DONATE:Log("Sql data succesfull initialized!", false)
end

function _DUSTCODE_DONATE:SqlQuery(Query)
	local returnValue = {}
	local q

	if IsMysql then
		q = self.Database:query(Query)
		q:start()
		q:wait(true)

		returnValue = q:getData()
	else
		q = self.Database.query(Query)
		returnValue = q
	end

	if (type(returnValue) != 'table') then return {} end

	return returnValue
end

--[[-------------------------------------------------------------------------
						CREATING SQL TABLES
---------------------------------------------------------------------------]]

if IsMysql then
	_DUSTCODE_DONATE:SqlQuery([[CREATE TABLE IF NOT EXISTS dustcode_players(
		id INT NOT NULL AUTO_INCREMENT,
		steamid VARCHAR(150),
		balance INT NOT NULL,
		PRIMARY KEY (id))]])

	_DUSTCODE_DONATE:SqlQuery([[CREATE TABLE IF NOT EXISTS dustcode_payments(
		id INT NOT NULL AUTO_INCREMENT,
		steamid VARCHAR(150),
		amount INT NOT NULL,
		serverip VARCHAR(150),
		date DATETIME,
		PRIMARY KEY (id))]])

	_DUSTCODE_DONATE:SqlQuery([[CREATE TABLE IF NOT EXISTS dustcode_buyeditems(
		id INT NOT NULL AUTO_INCREMENT,
		steamid VARCHAR(150),
		itemid VARCHAR(200) NOT NULL,
		activetime VARCHAR(255) NOT NULL,
		isactivated INT NOT NULL,
		isEquiped INT NOT NULL,
		PRIMARY KEY (id))]])
else
	_DUSTCODE_DONATE:SqlQuery([[CREATE TABLE IF NOT EXISTS dustcode_players(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		steamid VARCHAR(150),
		balance INT NOT NULL)]])

	_DUSTCODE_DONATE:SqlQuery([[CREATE TABLE IF NOT EXISTS dustcode_payments(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		steamid VARCHAR(150),
		amount INT NOT NULL,
		date DATETIME,
		serverip VARCHAR(150))]])

	_DUSTCODE_DONATE:SqlQuery([[CREATE TABLE IF NOT EXISTS dustcode_buyeditems(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		steamid VARCHAR(150),
		itemid VARCHAR(200) NOT NULL,
		activetime VARCHAR(255) NOT NULL,
		isEquiped INT NOT NULL,
		isactivated INT NOT NULL)]])
end

_DUSTCODE_DONATE.SqlInitialized = true

end