if defined? ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter
  # force any column ending in _id to be coerced into a Fixnum
  ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter.emulate_integers_by_column_name = true

  # for migrations, specify defaults for certain DB objects
  ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter.default_tablespaces =
    {clob: 'GD_ENC_XACT_CLOB01', index: 'GD_ENC_XACT_INDX01', table: 'GD_ENC_XACT_DATA01'}
end
