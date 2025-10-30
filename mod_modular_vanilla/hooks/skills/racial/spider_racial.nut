::ModularVanilla.MH.hook("scripts/skills/racial/spider_racial", function(q) {
	// VanillaFix: Add missing null check for `_targetEntity`
	// Buy report: https://steamcommunity.com/app/365360/discussions/1/652585180866921562/
	q.onAnySkillUsed = @() { function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_targetEntity != null && _targetEntity.getSkills().hasSkill("effects.web"))
		{
			_properties.DamageDirectMult *= 2.0;
		}
	}}.onAnySkillUsed;
});
