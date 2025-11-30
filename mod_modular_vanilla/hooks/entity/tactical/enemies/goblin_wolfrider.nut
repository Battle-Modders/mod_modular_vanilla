::ModularVanilla.MH.hook("scripts/entity/tactical/enemies/goblin_wolfrider", function (q) {
	// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/685238975203487639/
	// Goblin Wolfrider does not properly flip or adjust offset of its sprites
	// and appears bad when allied with player.
	// We add logic to flip and adjust offset of the relevant sprites.
	q.onFactionChanged = @(__original) { function onFactionChanged()
	{
		__original();
		local flip = this.isAlliedWithPlayer();

		local offset = ::createVec(flip ? -8 : 8, 14);
		this.setSpriteOffset("body", offset);
		this.setSpriteOffset("armor", offset);
		this.setSpriteOffset("head", offset);
		this.setSpriteOffset("injury", offset);
		this.setSpriteOffset("helmet", offset);
		this.setSpriteOffset("helmet_damage", offset);
		this.setSpriteOffset("body_blood", offset);

		this.setSpriteOffset("arms_icon", ::createVec(flip ? -15 : 15, 15));

		this.getSprite("wolf").setHorizontalFlipping(flip);
		this.getSprite("wolf_head").setHorizontalFlipping(flip);
		this.getSprite("wolf_armor").setHorizontalFlipping(flip);
	}}.onFactionChanged;
});
