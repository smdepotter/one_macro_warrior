Printd("SM_extend.lua loaded OK!")
SLASH_INIT1="/init"
SlashCmdList["INIT"]=function()
	init()
end


function init()
--Adds keybinds to Actionbar
  local class=UnitClass("player")
  SetActionBarToggles(1,1,1,1,1)
  SHOW_MULTI_ACTIONBAR_1=1
  SHOW_MULTI_ACTIONBAR_2=1
  SHOW_MULTI_ACTIONBAR_3=1
  SHOW_MULTI_ACTIONBAR_4=1
  ALWAYS_SHOW_MULTI_ACTIONBAR=1
  MultiActionBar_Update()
  local index=CreateMacro("aoe",326,"/script aoe()",1,1)
  PickupMacro(index)
  PlaceAction(1)
  PickupMacro(index)	
  PlaceAction(73)
  PickupMacro(index)
  PlaceAction(85)
  PickupMacro(index)
  PlaceAction(97)
  PickupMacro(index)
  PlaceAction(109)
  index=CreateMacro("single",134,"/script single()",1,1)
  PickupMacro(index)
  PlaceAction(2)
  PickupMacro(index)
  PlaceAction(74)
  PickupMacro(index)
  PlaceAction(86)
  PickupMacro(index)
  PlaceAction(98)
  PickupMacro(index)
  PlaceAction(110)
  if class=="Warrior" and SpellExists("Shoot") then 
    PickupSpell(SpellNum("Shoot "..RangedWeaponType()),BOOKTYPE_SPELL)
    PlaceAction(61)
  end
  PickupSpell(SpellNum("Attack"),BOOKTYPE_SPELL)
    PlaceAction(62)
  ClearTutorials()
  ReloadUI()
end
--------**DETERMINERS**----------
function SpellExists(findspell)
	for i = 1, MAX_SKILLLINE_TABS do
		local name, texture, offset, numSpells = GetSpellTabInfo(i);

		if not name then
			break;
		end

		for s = offset + 1, offset + numSpells do
			local	spell, rank = GetSpellName(s, BOOKTYPE_SPELL);

			if rank then
				local spell = spell.." "..rank;
			end
			if string.find(spell,findspell,nil,true) then 
				return true
			end
		end
	end
end
function RangedWeaponType()
	local itemLink = GetInventoryItemLink("player",18)
	if not itemLink then return "Bow" end
	local bsnum=string.gsub(itemLink,".-\124H([^\124]*)\124h.*", "%1")
	local itemName, itemNo, itemRarity, itemReqLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemIcon = GetItemInfo(bsnum)
	_,_,itemSubType=string.find(itemSubType,"(.*)s")
	return(itemSubType)
end
function SpellNum(spell)
 local i = 1
 local spellName
 while true do
    spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
    if not spellName or spell==spellName then
       do break end
    end
    i = i + 1
 end
 if spellName == nil then Printd("Error! Spell " .. spell .. " does not exist in spellbook! " ) ; end
 return i
end
function DotCast(spell)
 --This cast function only casts if the target is not already buffed with the spell
 local name,realm=UnitName("target")
 if not name or not UnitIsConnected("target") or UnitIsDead("target") or UnitIsGhost("target") then return end
 if not buffed(spell,"target") then cast(spell) end
end
function StackCast(spell,numstacks)
 local spell_icon=GetSpellTexture(SpellNum(spell),BOOKTYPE_SPELL)
 local count,icon
 for i=1,16 do 
  icon,count,bufftype,duration,expiration,caster = UnitDebuff("target",i) 
  if icon==spell_icon then
   break ; end
 end
 if not count then count=0 end
 if count<numstacks then  
   if count>=numstacks then CooldownCast(spell,20) else cast(spell) end
 end
end	
function MyHealthPct()
	return UnitHealth("player")/UnitHealthMax("player")
end
function InCombat()
	return UnitAffectingCombat("player")
end
function OnCooldown(spell)
--Important helper function that returns true(actually the duration left) if a spell is on cooldown, nil if not.
  if not SpellExists(spell) then return true end
  local start,duration,enable = GetSpellCooldown(SpellNum(spell),BOOKTYPE_SPELL)
  if duration==0 then 
	  return
  else 
          return duration
  end
end
function StanceCast(stance)
--Changes stances only if you are not already there
  local stanceno
  local texture,name,isActive,isCastable = GetShapeshiftFormInfo(1)
  if isActive then currstance=1 ; end
  local texture,name,isActive,isCastable = GetShapeshiftFormInfo(2)
  if isActive then currstance=2 ; end
  local texture,name,isActive,isCastable = GetShapeshiftFormInfo(3)
  if isActive then currstance=3 ; end
  if UnitClass("player")=="Warrior" then
    if stance=="Battle Stance"
    then stanceno=1
    elseif stance=="Defensive Stance"
    then stanceno=2
    elseif stance=="Berserker Stance"
    then stanceno=3
    end
 elseif UnitClass("player")=="Druid" then
    if stance=="Dire Bear Form"
    then stanceno=1
    elseif stance=="Aquatic Form"
    then stanceno=2
    elseif stance=="Cat Form"
    then stanceno=3
    elseif stance=="Travel Form"
    then stanceno=4
    elseif stance=="Moonkin Form"
    then stanceno=5
    elseif stance=="Tree of Life Form"
    then stanceno=6
  end
 end
 if stanceno~=currstance
 then cast(stance)
 end
end
function InMeleeRange()
  return CheckInteractDistance("target",3)
end
function TargetNotOnMe()
	if UnitName("playertargettarget")~=UnitName("player") then Taunt()
	end
end
function MyRage()
  return UnitMana("player")
end
function MyStance()
--Returns a number representing what stance you are in
 local currstance
 local texture,name,isActive,isCastable = GetShapeshiftFormInfo(1)
 if isActive then currstance=1 ; end
 local texture,name,isActive,isCastable = GetShapeshiftFormInfo(2)
 if isActive then currstance=2 ; end
 local texture,name,isActive,isCastable = GetShapeshiftFormInfo(3)
 if isActive then currstance=3 ; end
 return currstance
end

----------**ABILITIES**----------
function single()
	if MyHealthPct()<=.07 then UseHealthStone() ; cast("Last Stand") end -- Add Greater Healing Potion
	if MyHealthPct()<=.2 then cast("Shield Wall") end
	if IsShiftKeyDown() then Charge() end
	if not InCombat() then BerserkerRage() UseAction(61) end
	TargetNotOnMe()
	AutoAttack()
	cast("Bloodrage")
	if MyRage()>=10 then  -- Consider Change to 15. Allow Extra rage to pool into Mocking Blow
		StanceCast("Defensive Stance") cast("Shield Block") cast("Revenge")
		if not buffed("Thunder Clap","target") and not OnCooldown("Thunder Clap") and MyRage()>=20 then
			cast("Thunder Clap") 
			StanceCast("Battle Stance") 
		end
	  DotCast("Demoralizing Shout") SelfBuff("Battle Shout") cast("Shield Bash") StackCast("Sunder Armor",5) cast("Heroic Strike") --- ADD DOT CAST THUNDERCLAP BACK IN
	end
end
function BerserkerRage()
	if not OnCooldown("Berserker Rage") then StanceCast("Berserker Stance") cast("Berserker Rage")
	end
end
function Charge() 
	if not InCombat() and not InMeleeRange() and not OnCooldown("Charge") then
		BerserkerRage() StanceCast("Battle Stance") UseAction(61) cast("Charge")
	end
	if InCombat() and not InMeleeRange() and MyRage()>=10 and not OnCooldown("Intercept") then
		StanceCast("Berserker Stance")  cast("Intercept") 
	end
end
function UseHealthStone()
	use("Major Healthstone") 
	use("Greater Healthstone") 
	use("Healthstone") 
end
function AutoAttack()	
	if not IsCurrentAction(62) then UseAction(62) end;
end
function Taunt()
	if not OnCooldown("Taunt") then 
		StanceCast("Defensive Stance") 
		cast("Taunt")  
	end
	if not OnCooldown("Mocking Blow") and MyRage()>9 and MyStance()==1 then 
		cast("Mocking Blow") 
	end  
	if not OnCooldown("Mocking Blow") and MyRage()>9 then 
		StanceCast("Battle Stance") 
	end
end
function SelfBuff(spell)
--Important spell which allows a player to buff themselves without recasting. Only buffs if you don't have buff
if not buffed(spell,"player") then
	CastSpellByName(spell,1)
end
end