// This is a copy of the vanilla WeakTableRef code
// except the VanillaFix below.
::WeakTableRef = class
{
	WeakTable = null;

	// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/796715232585243274/
	// Vanilla WeakTableRef does not handle creation from instances of WeakTableRef
	// leading to a null WeakTable inside. We fix this by adding a check for _table being
	// instance of WeakTableRef.
	constructor( _table )
	{
		if (_table instanceof ::WeakTableRef)
		{
			_table = _table.get();
		}

		if (_table != null && typeof _table == "table")
		{
			this.WeakTable = _table.weakref();
		}
	}

	function isNull()
	{
		return this.WeakTable == null;
	}

	function get()
	{
		return this.WeakTable;
	}

	function _get( _index )
	{
		if (_index in this)
		{
			return this[_index];
		}
		else if (this.WeakTable == null)
		{
			throw null;
		}
		else
		{
			local result = this.WeakTable[_index];

			if (result != null && typeof result == "function")
			{
				result = result.bindenv(this.WeakTable);
			}

			return result;
		}
	}
};
