SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO


CREATE TABLE [dbo].[CDKey](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Account] [varchar](16) COLLATE Chinese_PRC_CI_AS NOT NULL,
	[PassWord] [varchar](16) COLLATE Chinese_PRC_CI_AS NOT NULL,
	[CardID] [int] NULL CONSTRAINT [DF_CDKey_CardID]  DEFAULT ((0)),
	[GameGold] [int] NULL CONSTRAINT [DF_CDKey_GameGold]  DEFAULT ((0)),
	[UserName] [varchar](12) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF_CDKey_UserName]  DEFAULT (''),
	[BirthDay] [varchar](20) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF_CDKey_BirthDay]  DEFAULT (''),
	[Quiz1] [varchar](20) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF_CDKey_Quiz1]  DEFAULT (''),
	[Answer1] [varchar](20) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF_CDKey_Answer1]  DEFAULT (''),
	[Quiz2] [varchar](20) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF_CDKey_Quiz2]  DEFAULT (''),
	[Answer2] [varchar](20) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF_CDKey_Answer2]  DEFAULT (''),
	[EMail] [varchar](30) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF_CDKey_EMail]  DEFAULT (''),
	[Phone] [varchar](14) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF_CDKey_Phone]  DEFAULT (''),
	[MobilePhone] [varchar](14) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF_CDKey_MobilePhone]  DEFAULT (''),
	[IdentityCard] [varchar](18) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF_CDKey_IdentityCard]  DEFAULT (''),
	[RegDateTime] [datetime] NULL CONSTRAINT [DF_CDKey_RegDateTime]  DEFAULT (getdate()),
	[LoginDateTime] [datetime] NULL CONSTRAINT [DF_CDKey_LoginDateTime]  DEFAULT (getdate()),
 CONSTRAINT [PK_CDKey] PRIMARY KEY CLUSTERED 
(
	[Account] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[GMAE_CHRNAME](
	[sChrName] [varchar](16) COLLATE Chinese_PRC_CI_AS NOT NULL,
 CONSTRAINT [PK_GMAE_CHRNAME] PRIMARY KEY CLUSTERED 
(
	[sChrName] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[GMAE_GUILDNAME](
	[sGuildName] [varchar](30) COLLATE Chinese_PRC_CI_AS NOT NULL,
 CONSTRAINT [PK_GMAE_GUILDNAME] PRIMARY KEY CLUSTERED 
(
	[sGuildName] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[MatrixCard](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Card_No] [varchar](16) COLLATE Chinese_PRC_CI_AS NOT NULL,
	[CDKeyID] [int] NULL CONSTRAINT [DF_Table_1_CDKey_ID]  DEFAULT ((0)),
	[ApplyTime] [datetime] NULL CONSTRAINT [DF_Table_1_ApplyTime]  DEFAULT (getdate()),
	[Card_1] [tinyint] NOT NULL,
	[Card_2] [tinyint] NOT NULL,
	[Card_3] [tinyint] NOT NULL,
	[Card_4] [tinyint] NOT NULL,
	[Card_5] [tinyint] NOT NULL,
	[Card_6] [tinyint] NOT NULL,
	[Card_7] [tinyint] NOT NULL,
	[Card_8] [tinyint] NOT NULL,
	[Card_9] [tinyint] NOT NULL,
	[Card_10] [tinyint] NOT NULL,
	[Card_11] [tinyint] NOT NULL,
	[Card_12] [tinyint] NOT NULL,
	[Card_13] [tinyint] NOT NULL,
	[Card_14] [tinyint] NOT NULL,
	[Card_15] [tinyint] NOT NULL,
	[Card_16] [tinyint] NOT NULL,
	[Card_17] [tinyint] NOT NULL,
	[Card_18] [tinyint] NOT NULL,
	[Card_19] [tinyint] NOT NULL,
	[Card_20] [tinyint] NOT NULL,
	[Card_21] [tinyint] NOT NULL,
	[Card_22] [tinyint] NOT NULL,
	[Card_23] [tinyint] NOT NULL,
	[Card_24] [tinyint] NOT NULL,
	[Card_25] [tinyint] NOT NULL,
	[Card_26] [tinyint] NOT NULL,
	[Card_27] [tinyint] NOT NULL,
	[Card_28] [tinyint] NOT NULL,
	[Card_29] [tinyint] NOT NULL,
	[Card_30] [tinyint] NOT NULL,
 CONSTRAINT [PK_MatrixCard] PRIMARY KEY CLUSTERED 
(
	[Card_No] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF

GO
SET ANSI_NULLS ON

GO
SET QUOTED_IDENTIFIER ON

GO
CREATE PROCEDURE CheckUserLogin

	@UserAccount	varchar(20),
	@UserPassWord	varchar(32),
	@UserID	int output,
	@UserGold int output

AS
	SET NOCOUNT ON
	SET @UserID = 0
	SET @UserGold = 0
	if (@UserAccount is null) or (@UserPassWord is null)
		return -1	--帐号密码不能为空 
	
	/*	
	--判断帐号是否存在
	if not exists(SELECT Account FROM CDKey where Account = @UserAccount)
		return -1	--帐号不存在*/

	DECLARE @DBPassWord varchar(32)
	DECLARE @DBCardID int
	DECLARE @DBGold int
	SET @DBPassWord = null
	SET @DBCardID = 0
	SET @DBGold = 0
		
	--取该帐号密码和密码卡ID
	SELECT 
		@UserID = ID,
		@DBPassWord = PassWord,  
		@DBCardID = CardID,
		@DBGold = GameGold
	FROM 
		CDKey 
	where 
		Account = @UserAccount
	
	--判断数据库密码与提交密码是否相同
	if (@DBPassWord is null) or (@DBPassWord <> @UserPassWord)
		return -2 --密码不正确

	if not (@UserGold is null)
		SET @UserGold = @DBGold

	return @DBCardID + 1 --验证通过，返回密码卡ID

GO

CREATE PROCEDURE [CreateGoldLogTable]

		@error	int output,
		@TableName varchar(50)

AS

	SET NOCOUNT ON;
	
	DECLARE @Sql varchar(500)
	SET @error = 0

	--判断表是否存在，不存在则创建
	if not exists(select * from sysobjects where xtype = 'u' and id = object_id(@TableName))
	begin
		SET @Sql = 'CREATE TABLE [' + @TableName + '](' + 
					'[ID] [int] IDENTITY(1,1) NOT NULL,' +
					'[Account] [varchar](20) NOT NULL,' +
					'[ChrName] [varchar](16) NOT NULL,' +
					'[LogIndex] [int] NOT NULL,' +
					'[ServerNsme] [varchar](20) NOT NULL,' +
					'[OldGoldCount] [int] NOT NULL,' +
					'[NewGoldCount] [int] NOT NULL,' +
					'[ChangeCount] [int] NOT NULL,' +
					'[IsAdd] [bit] NOT NULL,' +
					'[AddTime] [datetime] NULL CONSTRAINT [DF_' + @TableName + 
					'_AddTime] DEFAULT (getdate())' +
					') ON [PRIMARY]'
		EXEC(@SQL)
		SET @error = @@error
	end

GO
CREATE PROCEDURE [CreateGuildName]

		@sGuildName		VarChar(30)

AS

	SET NOCOUNT ON;
	if exists (SELECT * FROM GMAE_GUILDNAME WHERE sGuildName = @sGuildName)
		return -1	--创建的行行名称已经存在

	INSERT INTO GMAE_GUILDNAME (sGuildName) values (@sGuildName) 
	if @@error <> 0 return -2
	else return 1


GO
CREATE PROCEDURE [dbo].[CreateNewCDKey]

		@sAccount	VarChar(16),
		@sPassWord	VarChar(16),
		@sEMail		VarChar(30)='',
		@sUserName	VarChar(12)='',
		@sBirthDay	VarChar(20)='',
		@sQuiz1		VarChar(20)='',
		@sAnswer1	VarChar(20)='',
		@sQuiz2		VarChar(20)='',
		@sAnswer2	VarChar(20)='',
		@sPhone		VarChar(14)='',
		@sMobilePhone  VarChar(14)='',
		@sIdentityCard VarChar(18)=''
		
		
AS

	SET NOCOUNT ON;
	INSERT INTO CDKey 
		(Account, PassWord, UserName, BirthDay, 
			Quiz1, Answer1, Quiz2, Answer2, EMail, Phone, MobilePhone, IdentityCard) 
	values 
		(@sAccount, @sPassWord, @sUserName, @sBirthDay, 
			@sQuiz1, @sAnswer1, @sQuiz2, @sAnswer2, @sEMail, @sPhone, @sMobilePhone, @sIdentityCard) 
	return @@error



GO
CREATE PROCEDURE [CreateNewChr]

	@sChrName	VarChar(20)

AS

	SET NOCOUNT ON;
	if exists (SELECT * FROM GMAE_CHRNAME WHERE sChrName = @sChrName)
		return -1	--创建的人物已经存在

	INSERT INTO GMAE_CHRNAME (sChrName) values (@sChrName) 
	if @@error <> 0 return -2
	else return 1


GO
CREATE PROCEDURE [GameGoldChange] 

		@GoldCount	int output,
		@AccountID	int,
		@Account	varchar(20),
		@ChrName	varchar(16),
		@LogIndex	int,
		@ServerName	varchar(20),
		@IsAdd		bit	

AS

	SET NOCOUNT ON;
	if @GoldCount <= 0 or @AccountID <= 0 or @Account = '' 
		return -1 --信息不完整

	DECLARE @error int
	DECLARE @GameGoldCount int
	DECLARE @TableName varchar(50)
	DECLARE @DateTime datetime
	SET @GameGoldCount = @GoldCount
	SET @error = 0
	SET @DateTime = GetDate()
	SET @TableName = 'GoldLog_' + convert(varchar, Year(@DateTime)) + '_' +
					 convert(varchar, Month(@DateTime))
	
	EXEC CreateGoldLogTable @error, @TableName --调用创建LOG表过程
	if (@error <> 0)
		return -2	--创建日志表失败

	DECLARE @OldDBGold int
	DECLARE @NewDBGold int
	SET @OldDBGold = null
	SET @NewDBGold = 0

	SELECT 
		@OldDBGold = GameGold
	FROM 
		CDKey 
	where 
		ID = @AccountID and
		Account = @Account

	

	if @OldDBGold is null
		return -3	--账号不存在

	SET @GoldCount = @OldDBGold

	if (@IsAdd = 0) and ((@OldDBGold <= 0) or (@OldDBGold < @GameGoldCount))
		return -4	--元宝数量不够

	IF (@IsAdd = 1) AND (@OldDBGold + @GameGoldCount >= 99999999)
		return -5	--元宝数量太多
	
	if (@IsAdd = 0)
		SET @NewDBGold = @OldDBGold - @GameGoldCount
	ELSE
		SET @NewDBGold = @OldDBGold + @GameGoldCount 

	BEGIN TRAN IN_TEST	--创建回滚事务

	UPDATE	
		CDKEY
	SET
		GameGold = @NewDBGold
	where
		ID = @AccountID

	DECLARE @SQL char(500)
	if @@error = 0
	begin
		SET @SQL = 'INSERT INTO ' + @TableName +
				   ' (Account, ChrName, LogIndex, ServerNsme, OldGoldCount, NewGoldCount, ChangeCount, IsAdd) ' +
				   'values (''' + 
				   @Account + ''',''' +
				   @ChrName + ''',' +
				   convert(varchar, @LogIndex) + ',''' +
				   @ServerName + ''',' +
				   convert(varchar, @OldDBGold) + ',' +
				   convert(varchar, @NewDBGold) + ',' +
				   convert(varchar, @GameGoldCount) + ',' +
				   convert(varchar, @IsAdd) + ')'
		EXEC(@SQL)
		if @@error <> 0
		begin
			
			ROLLBACK TRAN IN_TEST
			return -6	--系统错误
		end
		else
		begin
			SET @GoldCount = @NewDBGold
			COMMIT TRAN IN_TEST
			return 1	--成功
		end
	end
	ROLLBACK TRAN IN_TEST
	return -6	--系统错误

GO
CREATE PROCEDURE [GetMatrixCardNo] 

	@CardID		int,
	@CardNo1	int,
	@CardNo2	int,
	@CardNo3	int

AS

	SET ROWCOUNT 1;
	DECLARE @Sql char(255)

	SET @Sql = 'SELECT [No1] = Card_' + 
				convert(char, @CardNo1) + ', [No2] = Card_' + 
				convert(char, @CardNo2) + ', [No3] = Card_' + 
				convert(char, @CardNo3) + ' FROM MatrixCard where Id = ' + 
				convert(char, @CardID)
	EXEC(@Sql)
	return @@error

GO
CREATE PROCEDURE [CheckCDKey] 

	@UserAccount	varchar(20)
AS

	SET NOCOUNT ON;
	if exists(SELECT * FROM CDKey where Account = @UserAccount)
		return 1	--帐号存在*/
	return 0 --账号不存在

