# DESCRIPTION
Modular Vanilla is an ambitious project whose primary goal is to allow modders to be able to change/tweak vanilla functionality in a more compatible way. This is achieved by doing the following:
- Break down large vanilla functions (e.g. `skill.attackEntity` and `actor.onDamageReceived`) into new smaller modular functions so that modders can hook/change specific stuff.
- Add new functions/fields/classes which carry and pass around more information, to allow modders to access and change it e.g. a new `::Const.Tactical.MV_AttackInfo` which contains information about the attack similar to the vanilla `HitInfo`.
- Add new functionality to be able to mod at a more granular level e.g. new kinds of morale checks.
- Improve vanilla code to be more DRY (Don't Repeat Yourself) so that changes made to one function properly extend to all the places where that function would be relevant e.g. vanilla copy pastes and repeats code in various places instead of using a centralized function an example of which is the `skill.getHitchance` whose entire functionality is rewritten in `skill.attackEntity`.

Modular Vanilla is meant to be a community project so all modders are welcome to create issues, create PRs, propose new features and discuss existing ones.

# FEATURES

# Vanilla Fixes
### turn_sequence_bar.onEntityEntersFirstSlot
Original bug report: https://steamcommunity.com/app/365360/discussions/1/604155219069147354/.

Vanilla calls this function whenever an entity who is visible in the turn sequence bar is pushed back in the sequence resulting in calling `entity.onTurnResumed` on the currently active actor prematurely. Our fix is a bandaid which returns early when calling this function on an entity already in the first slot.

### Dislocated Shoulder injury
Original bug report: https://steamcommunity.com/app/365360/discussions/1/555745444093769921/

Vanilla sets the action points during `onUpdate` which makes changes from other skills to not be properly accounted for. We have moved it to `onAfterUpdate` as it should be.

### Lindwurm Body being null during Tail death
Keep a strong reference to the body while the lindwurm_tail is being killed and only nullify it with a delayed event. Otherwise attempts to call `_targetEntity.getCurrentProperties()` in things such as `skill.onTargetHit` result in an exception because `m.Body` has become null and lindwurm tail tries to return `m.Body.m.CurrentProperties` in its `getCurrentProperties()`. Vanilla gets around this issue by manually checking for `isKindOf(target, "lindwurm_tail")` in `cleave.nut` which is ugly. With our fix no such workaround is necessary and the properties can be accessed during skill_container events without any crash or error.

## Const
### MV_HireableCharacterBackgrounds
```squirrel
:Const.MV_HireableCharacterBackgrounds
```
Modular Vanilla adds this array that is populated with the filenames of all backgrounds which are hireable from settlements. This list is populated during the `AfterHooks` queue bucket automatically by iterating over all `settlement` with their `.m.DraftList` and `attached_location`, `building` and `situation` with their `onUpdateDraftList` functions. You can also push manual entries to this list, but this should be done before `AfterHooks`.

## Const.MoraleCheckType
MV adds the following new morale check types. Naturally, each morale check type can also be used in the `properties.MoraleCheckBravery` and `properties.MoraleCheckBraveryMult` arrays.
- `MV_Surround`: Is now used as the type of morale check that is triggered from `actor.onMovementFinish`.

## Const.Tactical
### HitInfo
#### New Fields
MV adds the following new fields to `::Const.Tactical.HitInfo` to make more information available in the functions where it is passed.
```squirrel
hitInfo.MV_ArmorRemaining
```
This field contains the armor remaining on the character after the armor damage from the hit would be applied.
```squirrel
hitInfo.MV_PropertiesForUse
```
This is the user's properties built via `skill_container.buildPropertiesForUse`. This is added to the HitInfo during `skill.MV_initHitInfo` which happens during the vanilla `skill.onScheduledTargetHit` function.
```squirrel
hitInfo.MV_PropertiesForDefense
```
This is the target's properties built via `skill_container.buildPropertiesForDefense`. This is added to the HitInfo during `skill.onScheduledTargetHit`.
```squirrel
hitInfo.MV_PropertiesForBeingHit
```
This is the target's properties built via `skill_container.builtPropertiesForBeingHit`. This is added to the HitInfo during the target's `actor.onDamageReceived`.

#### MV_CurrentHitInfo
We also expose the current attack's HitInfo globally making it accessible even from functions where it is not passed directly. This can be accessed as
```squirrel
::Const.Tactical.MV_CurrentHitInfo
```
As this is a weakref, it is important to first check if it is null or not.

### MV_AttackInfo
MV adds this new object to `::Const.Tactical` and it is meant to be an analogue to the vanilla `::Const.Tactical.HitInfo` but contains information about the attack, not the hit. This object is created during `skill.attackEntity` and is passed around to the various modular functions. See the modularization of `skill.attackEntity` for details.
```
MV_AttackInfo = {
	ChanceToHit = null,
	Roll = null,
	AllowDiversion = true,
	IsAstray = false,
	User = null,
	Target = null
	PropertiesForUse = null,
	PropertiesForDefense = null
}
```

## Const.Combat
MV adds the following new fields to the `::Const.Combat` table:
```squirrel
::Const.Combat.MV_HitChanceMin = 5
::Const.Combat.MV_HitChanceMax = 95
```
These values are used to set the default minimum and maximum hit-chance which is then used in the modular `skill.MV_getHitchance` function to set the limits.

```squirrel
::Const.Combat.MV_DiversionHitChanceAdd = -15
```
This is the modifier to the hitchance for a diverted ranged attack. It defaults to the vanilla -15% and is used in the modularization of `skill.attackEntity`.

```squirrel
::Const.Combat.MV_DiversionDamageMult = 0.75
```
This is a multiplier to the damage for a diverted ranged attack. It defaults to the vanilla 0.75 and is used in the modularization of `skill.attackEntity`.

## ACTOR
### Modularization of actor.onDamageReceived
The `actor.onDamageReceived` function is a large monolithic function in vanilla that does many things. It also is completely overwritten and has a custom implementation for `lindwurm_tail`. We have modularized this function and have also adjusted `lindwurm_tail` code to now use this standard function from `actor`. This keeps things DRY.

#### MV_calcArmorDamageReceived
```squirrel
actor.MV_calcArmorDamageReceived( _skill, _hitInfo )
// _skill is the skill being used to hit the actor
// _hitInfo is the ::Const.Tactical.HitInfo object related to this hit
```
The `_hitInfo.MV_PropertiesForBeingHit` must be populated before calling this function. Calculates and returns the armor damage that this character would receive from this hit. Also calculates and sets the following fields in the `HitInfo`:
- DamageArmor
- MV_ArmorRemaining
- DamageInflictedArmor

#### MV_calcHitpointsDamageReceived
```squirrel
actor.MV_calcHitpointsDamageReceived( _skill, _hitInfo )
```
The `_hitInfo.MV_PropertiesForBeingHit` must be populated before calling this function. Calculates and returns the hitpoints damage that this character would receive from this hit. Also calculates and sets the following fields in the `HitInfo`:
- DamageRegular
- DamageInflictedHitpoints

#### MV_calcFatigueDamageReceived
```squirrel
actor.MV_calcFatigueDamageReceived( _skill, _hitInfo )
```
The `_hitInfo.MV_PropertiesForBeingHit` must be populated before calling this function. Calculates and returns the fatigue damage that this character would receive from this hit. Also calculates and sets the following fields in the `HitInfo`:
- DamageFatigue

#### MV_getFatalityType
```squirrel
actor.MV_getFatalityType( _skill, _hitInfo )
```
Returns the fatality type that the used skill would inflict in this hit.

#### MV_onInjuryReceived
```squirrel
actor.MV_onInjuryReceived( _injury )
```
Is called in the modularization of `actor.onDamageReceived` when the character takes an injury. In vanilla this is used to lower the mood of bros.

#### MV_applyInjury
```squirrel
actor.MV_applyInjury( _skill, _hitInfo )
```
Extraction of the injury application logic from `actor.onDamageReceived`. Selects a valid applicable injury from `_hitInfo.Injuries` and applies to the character. Then calls `actor.MV_onInjuryReceived` if an injury was applied.

#### MV_onBeforeDeathConfirmed
Documentation pending.

#### MV_checkMoraleOnDamageReceived
Documentation pending.

### Modularization of actor.onMovementFinish
Documentation pending.

## PLAYER
### Modularization of player.setStartValuesEx
MV modularizes this function to extract the addition of traits to a bro. These extracted functions are helpful for not only modifying the number of starting traits that bros should spawn with but also to add traits to existing bros in a controlled fashion.

#### setStartValuesEx
The vanilla logic of adding traits in the `player.setStartValuesEx` function is flawed in the sense that it randomly roll a trait from the `::Const.CharacterTraits` array and adds it to the character if the trait isn't excluded by the character's background and existing traits. Vanilla repeats this process a maximum of 10 times. This results in edge cases where the desired number of traits are not added because in the 10 attempts it did not randomly roll enough number of valid traits.

MV fixes this vanilla logic to now filter through the array as many times as necesary to add the number of traits returned by the `MV_getMaxStartingTraits` function, or until the array is fully exhausted.

#### MV_getMaxStartingTraits
```squirrel
player.MV_getMaxStartingTraits()
```
Returns an integer which is the desired number of traits that this character should spawn with.

#### MV_addTraits
```squirrel
player.MV_addTraits( _amount )
// _amount is an integer
```
Adds valid traits to a player fully taking into account the traits excluded by the character's background and existing traits. Returns an array which contains the traits which were added to the character.

## SKILLS
- The changes to `ActionPointCost` or `FatigueCostMult` inside all vanilla active skills are now applied incrementally instead of setting. This works in tandem with the MSU base values reset system to allow modders to incrementally change these values without having to order the changing skill after these active skills.

### Modularization of skill.attackEntity
Documentation pending.

### Affordability Preview
MV adds a more advanced version of skill affordability preview compared to the one provided by MSU. This advanced implementation may be ported over to MSU once we are sure that it is stable. Documentation pending.

## BASE ITEM FOR NAMED ITEM
Note: This feature may be moved to MSU.
Modular Vanilla adds a `.m.BaseItemScript` field in `item`. This allows you to specify a base item for named items which will be used to copy various values from the `m` table of the base item to the named item before randomizing the values of the named item. Additionally, with the `.m.IsUsingBaseItemSkills` boolean which defaults to `true`, the named item will use the skills which the base item uses in its `onEquip` function.

This solves the age-old modding pitfall where a modder changes the values of a base item e.g. changes its `ArmorDamageMult` but forgets to do it for the named variant of that item. Similarly a modder may change the skills of a weapon e.g. remove Riposte, but forget to do it from the named variant.

It also makes it very easy to make named items based off of base items, without having to write duplicate code i.e. the skills and base stats of the named item.

### BaseItemScript
```squirrel
<item>.m.BaseItemScript
```
It is a string that is the file path of the base item e.g. `scripts/items/weapons/noble_sword`.

### IsUsingBaseItemSkills
```squirrel
<item>.m.IsUsingBaseItemSkills
```
Defaults to `true`. If true then the named item uses the skills that the base item gets. This effectively means that the `onEquip` function of the named item is ignored, and only that of the base item is used.

### getBaseItemFields
```squirrel
<item>.getBaseItemFields()
```
Returns an array of strings which are the keys in the `m` table of the base item. The values of these keys is copied over from the base item to the named item's respective fields before `randomizeValues` runs. By default Modular Vanilla includes implementations of this function in `named_weapon`, `named_armor` and `named_shield`. Modders can hook these functions to expand or reduce the fields that are meant to be copied. The exact implementations and the default fields copied should be seen inside the respective hooked file in the Modular Vanilla codebase.

## AI
Documentation pending.

## PLAYER PARTY
### Modularization of player_party.updateStrength
MV modularizes the way the strength of the player party is calculated, allowing modders to change how a single bro's strength is calculated and how the strength of empty slots is calculated. This includes adding some new functions in various classes such as `player_party` and `player` while also adding new strength-calculation related events in `skill_container` and `starting_scenario`.

#### MV_getEmptyBroStrength
```squirrel
<player_party>.MV_getEmptyBroStrength()
```
Returns the strength contribution of each "missing" bro from `::World.Assets.getBrothersScaleMin() - roster.len()` where roster is the current player roster. By default this returns 10.0 matching vanilla, but can be overwritten by mods.

#### MV_getStrengthRaw
```squirrel
<player>.MV_getStrengthRaw()
```
Returns the raw strength contribution of this bro to the player party strength. By default this uses the vanilla formula of `10.0 + (Level - 1) x 2`. However, this can be overwritten by mods.

#### MV_getStrength
```squirrel
<player>.MV_getStrength()
```
Returns the actual strength contribution of this bro to the player party strength. This is the `MV_getStrengthRaw()` along with any multipliers i.e. from `CurrentProperties.MV_StrengthMult`.

#### MV_StrengthMult
```squirrel
CharacterProperties.MV_StrengthMult
```
Allows skills to modify the contribution of a bro to the player party strength.

#### MV_getPlayerPartyStrengthMult
```squirrel
<starting_scenario>.MV_getPlayerPartyStrengthMult()
```
Returns a float which is a multiplier used in the `player_party.updateStrength()` function. Allows origins to modify the player party strength to make the scaling in that origin harder or easier.
