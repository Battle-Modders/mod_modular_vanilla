::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hook("scripts/ai/tactical/agent", function(q) {
		// MV: Added
		// part of MV_onUpdateAIAgent skill_container event
		q.m.MV_OriginalProperties <- null;
	});

	::ModularVanilla.MH.hookTree("scripts/ai/tactical/agent", function(q) {
		q.setActor = @(__original) function( _a )
		{
			__original(_a);
			// MV: Added
			// part of MV_onUpdateAIAgent skill_container event
			this.m.MV_OriginalProperties = ::MSU.deepClone(this.getProperties());
		}

		q.onUpdate = @(__original) function()
		{
			// MV: Added
			// part of MV_onUpdateAIAgent skill_container event
			this.m.Properties = ::MSU.deepClone(this.m.MV_OriginalProperties);
			this.getActor().getSkills().MV_onUpdateAIAgent();
			__original();
		}
	});
});
