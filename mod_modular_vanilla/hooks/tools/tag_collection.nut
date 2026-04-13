::ModularVanilla.MH.hook("scripts/tools/tag_collection", function(q) {
	q.onSerialize = @() { function onSerialize( _out )
	{
		::MSU.Serialization.serialize(::MSU.Table.map(this.m, @(_k, _v) [_k, _v.Value]), _out);
	}}.onSerialize;

	q.onDeserialize = @(__original) { function onDeserialize( _in )
	{
		if (::ModularVanilla.Mod.Serialization.isSavedVersionAtLeast("0.8.2", _in.getMetaData()))
		{
			foreach (k, v in ::MSU.Serialization.deserialize(_in))
			{
				this.set(k, v);
			}
		}
		else
		{
			__original(_in);
		}
	}}.onDeserialize;
});
