Type TLuaHandler
	Const BLOCK_FILE_PATH:String = "Blocks.lua"
	
	Global State:Byte Ptr
	
	Global Members:String[] = ..
	[ "Faces", "Transparent", "Colliding", "Flowing", "Transparency", ..
	  "TransparentIndex", "ID", "DisplayImage", "ForceBorders", ..
	  "Gravity", "IsObject", "ModelPath", "IsLight", "LightRadius", ..
	  "DestroyImage", "IsTrigger", "TriggeredOnTouch", "TriggeredBlock", ..
	  "ReplaceWith", "TriggeredOnAction", "ReplaceBlocks", "AdjustToNormal", ..
	  "LightR", "LightG", "LightB", "Masked", "MinimapColorR", "MinimapColorG", ..
	  "MinimapColorB" ]
	
	Function Init()
		State = luaL_newstate()
		
		luaL_openlibs( State )
		
		LoadAllBlocks()
	End Function
	
	Function LoadAllBlocks()
		lua_newtable( State )
		lua_setglobal( State, "Blocks" )
		
		Local Status:Int = luaL_loadfile( State, BLOCK_FILE_PATH )
		If Status Then Throw( "Lua Error: Error while loading lua script:~n~q"   + lua_tostring( State, 1 ) + "~q" )
		
		Status = lua_pcall( State, 0, 0, 0 )
		If Status Then Throw( "Lua Error: Error while executing lua script:~n~q" + lua_tostring( State, 1 ) + "~q" )
		
		lua_getglobal( State, "Blocks" )
		Local Index:Int = lua_gettop( State )
		
		lua_pushnil( State )
		While lua_next( State, Index )
			LoadSingleBlock()
			
			lua_pop( State, 1 )
		Wend
		lua_pop( State, 1 )
	End Function
	
	Function LoadSingleBlock()
		Local Block:TBlockClass = New TBlockClass
		
		Local Index:Int = lua_gettop( State )
		
		For Local Member:String = EachIn Members
			lua_getfield( State, Index, Member )
		Next
		
		Block.IsLight   = lua_toboolean( State, Index + 13 )
		
		Local FacesIndex:Int = lua_gettop( State ) + 1
		lua_getfield( State, Index + 1, "Left" )
		lua_getfield( State, Index + 1, "Right" )
		lua_getfield( State, Index + 1, "Front" )
		lua_getfield( State, Index + 1, "Back" )
		lua_getfield( State, Index + 1, "Top" )
		lua_getfield( State, Index + 1, "Bottom" )
		
		For Local I:Int = 0 Until 6
			Block.FaceTexture[ I ] = lua_tonumber( State, FacesIndex + I )
		Next
		
		If Block.IsLight Then
			Block.LightRadius    = lua_tonumber( State, Index + 14 )
			Block.LightR         = lua_tonumber( State, Index + 23 )
			Block.LightG         = lua_tonumber( State, Index + 24 )
			Block.LightB         = lua_tonumber( State, Index + 25 )
		EndIf
		
		Block.Transparent = lua_toboolean( State, Index + 2 )
		Block.Colliding   = lua_toboolean( State, Index + 3 )
		Block.Flowing     = lua_toboolean( State, Index + 4 )
		Block.Masked      = lua_toboolean( State, Index + 26 )
		
		If Block.Transparent Or Block.Masked Then
			If Not lua_isnil( State, Index + 5 ) Then Block.Transparency     =  lua_tonumber( State, Index + 5 )*0.5
			If Not lua_isnil( State, Index + 6 ) Then Block.TransparentIndex = -lua_tonumber( State, Index + 6 ) - 1
		EndIf
		
		Block.ID           = lua_tonumber ( State, Index + 7 )
		Block.ForceBorders = lua_toboolean( State, Index + 9 )
		
		lua_settop( State, Index )
		
		If TBlockClass.BlockArray[ Block.ID ] = Null Then
			TBlockClass.BlockArray[ Block.ID ] = Block
		Else
			Throw( "Lua Error: Duplicate block ID: " + Block.ID )
		EndIf
		
		Block.InitFields()
	End Function
End Type
