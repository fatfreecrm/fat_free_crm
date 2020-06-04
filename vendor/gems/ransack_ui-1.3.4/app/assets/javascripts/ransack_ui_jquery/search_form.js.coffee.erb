(($) ->
  $.widget 'ransack.ransack_search_form',
    options: {}

    _create: ->
      el = @element
      el.on 'click', '.add_fields',                $.proxy(@add_fields, this)
      el.on 'click', '.remove_fields',             $.proxy(@remove_fields, this)
      el.on 'change', 'select.ransack_predicate',  $.proxy(@predicate_changed, this)
      el.on 'change', 'select.ransack_attribute',  $.proxy(@attribute_changed, this)
      el.on 'change', 'input.ransack_query_multi', $.proxy(@multi_query_changed, this)

      # Store initial predicates and set up Select2 on select lists in .filters
      containers = el.find('.filters')
      if Select2?
        @init_select2(containers)
      @store_initial_predicates(containers)

      if $.ransack.button_group_select?
        @init_button_group_select(@element)

      # show spinner and disable the form when the search is underway
      el.find("form input:submit").click $.proxy(@form_submit, this)

      # Fire change event for any existing attribute selects,
      # set initialize to true so that existing queries are not cleared.
      el.find(".filters select.ransack_attribute").each (i, el) =>
        @attribute_changed({currentTarget: el}, true)

    attribute_changed: (e, initialize = false) ->
      target = $(e.currentTarget)
      selected_attribute = target.find('option:selected')
      column_type = selected_attribute.data('type')

      base_id = target.attr('id').slice(0, -8)
      predicate_select  = @element.find("select##{base_id}p")
      available = predicate_select.data['predicates']
      query_input = $("input##{base_id}v_0_value")
      multi_id = query_input.attr('id') + '_multi'
      multi_input = @element.find("##{multi_id}")
      query_select2_id = "#s2id_#{base_id}v_0_value"
      query_select2 = @element.find(query_select2_id)
      predicate_select2_id = "#s2id_#{base_id}p"
      predicate_select2 = @element.find(predicate_select2_id)

      # Initialize datepicker if column is date/datetime/time
      $.proxy(@init_datetimepicker, this)(base_id)

      # Clear input value unless this is the first run
      unless initialize
        query_input.val('')

      # Destroy any query select2 inputs on attribute change and clear input
      if query_select2.length
        query_input.select2('destroy')

      # Destroy any multi-inputs on attribute change and clear input
      if multi_input.length
        @destroy_multi_input(multi_input, selected_attribute.val())

      # Handle association columns with AJAX autocomplete
      if selected_attribute.data('ajax-url') and Select2?
        @set_option_predicates(base_id, available, column_type)

      # Handle columns with options detected from validates :inclusion
      else if selected_attribute.data('select-options') and Select2?
        @set_option_predicates(base_id, available, column_type, true)

      # Handle regular columns
      else
        if Select2?
          predicate_select2.select2("enable")

          # If Select2 is on query input, remove and set defaults
          if query_select2.length > 0
            query_input.select2('destroy')
            query_input.val('')
            previous_val = ''
          else
            previous_val = predicate_select.val()

        # Build array of supported predicates
        predicates = Ransack.type_predicates[column_type] || []
        predicates = $.map predicates, (p) -> [p, Ransack.predicates[p]]

        # Remove all predicates, and add any supported predicates
        predicate_select.find('option').each (i, o) -> $(o).remove()

        $.each available, (i, p) =>
          [predicate, label] = [p[0], p[1]]

          # Also allow compound predicates, unless column
          # is a date type. (No support for any/all on dates yet.)
          if !column_type?.match(/date|time/)
            p_key = predicate.replace(/_(any|all)$/, '')
          else
            p_key = predicate

          if p_key in predicates
            # Get alternative predicate label depending on column type
            label = @alt_predicate_label_or_default(predicate, column_type, label)
            predicate_select.append $("<option value=#{predicate}>#{label}</option>")

        # Select first predicate if current selection is invalid
        if Select2?
          predicate_select.select2('val', previous_val)

      # Run predicate_changed callback
      predicate_select.change()

      return true


    predicate_changed: (e) ->
      target   = $(e.currentTarget)
      p = target.val() || ""
      base_id = target.attr('id').slice(0, -1)
      query_input = $("input##{base_id}v_0_value")

      attribute_select  = @element.find("select##{base_id}a_0_name")
      selected_attribute = attribute_select.find('option:selected')

      query_select2_id = "#s2id_#{base_id}v_0_value"
      query_select2 = @element.find(query_select2_id)
      query_select2_multi_id = "#s2id_#{base_id}v_0_value_multi"
      query_select2_multi = @element.find(query_select2_multi_id)

      no_query_predicates = ["true", "false", "blank", "present", "null", "not_null"]

      # We need to use a dummy input to handle multiple terms
      multi_id = query_input.attr('id') + '_multi'
      multi_input = @element.find("##{multi_id}")

      # If query was previously hidden, clear query input
      if query_select2.length == 0 && multi_input.length == 0 && query_input.is(":hidden")
        query_input.val('')

      # Hide query input when not needed
      if p in no_query_predicates
        # If Select2 is on query input, remove and set defaults
        if Select2? && query_select2.length
          query_input.select2('destroy')

        query_input.val("true")
        query_input.hide()
        query_input.parent().find('.ui-datepicker-trigger').hide()

      if Select2?
        # Turn query input into Select2 tag list when query accepts multiple values
        if p in ["in", "not_in"] || p.match(/_(all|any)$/)
          # Add dummy 'multi' input for select2 if not already added
          if multi_input.length == 0 && query_select2_multi.length == 0
            # Set up multi-query input with fixed options, if present
            @setup_multi_query_input(target, query_input, multi_id, selected_attribute)

          # If Select2 is on query input, remove and set defaults
          if query_select2.length
            query_input.select2('destroy').hide()

          return

        else
          # Otherwise, remove Select2 from multi-query input, and remove input.
          if multi_input.length
            # Save label data from first value
            if multi_input.select2('data') && multi_input.select2('data').length
              multi_input_data = multi_input.select2('data').first()
              Ransack.value_field_labels[selected_attribute.val()] ||= {}
              Ransack.value_field_labels[selected_attribute.val()][multi_input_data.id] = multi_input_data.text

            @destroy_multi_input(multi_input, selected_attribute.val())

          if p not in no_query_predicates
            #query_input.show()
            query_input.css('display', '')

            # Handle association columns with AJAX autocomplete
            if selected_attribute.data('ajax-url')
              if query_select2.length
                query_input.hide()
              else
                @setup_select2_association(query_input, selected_attribute)

            # Handle fixed options - set up Select2 for single values if not already present
            if selected_attribute.data('select-options')
              if query_select2.length
                query_input.hide()
              else
                @setup_select2_options(query_input, selected_attribute)

      # Otherwise, reset query input and show datepicker trigger if present
      if p not in no_query_predicates
        return if selected_attribute.data('select-options')

        # Don't show query input if ajax auto complete is present on selected attribute
        unless p in ['eq', 'not_eq'] and selected_attribute.data('ajax-url')
          unless query_input.is(":visible")
            query_input.val('')
            #query_input.show()
            query_input.css('display', '')
            query_input.parent().find('.ui-datepicker-trigger').show()


    # Disables predicate choices and sets it to 'eq'
    set_option_predicates: (base_id, available_predicates, column_type, include_number_predicates = false) ->
      predicate_select  = @element.find("select##{base_id}p")
      previous_val = predicate_select.val()

      # Remove all predicates, and add any supported predicates
      predicate_select.find('option').each (i, o) -> $(o).remove()

      allowed_predicates = $.merge([], Ransack.option_predicates)

      # Include number predicates if the option was given.
      # For example, a integer column will have fixed select options,
      # but will also allow less than and greater than.
      if column_type in ['integer', 'float', 'decimal'] && include_number_predicates
        allowed_predicates = allowed_predicates.concat(Ransack.type_predicates[column_type] || [])

      $.each available_predicates, (i, p) =>
        [predicate, label] = [p[0], p[1]]

        if predicate in allowed_predicates
          # Get alternative predicate label depending on column type
          label = @alt_predicate_label_or_default(predicate, column_type, label)
          predicate_select.append $("<option value=#{predicate}>#{label}</option>")

      # Select first predicate if current selection is invalid
      predicate_select.select2('val', previous_val)

    # Attempts to find a predicate translation for the specific column type,
    # or returns the default label.
    # For example, 'lt' on an integer column will be translated to 'is less than',
    # while a date column will have it translated as 'is before'.
    # This is mainly to avoid confusion when building conditions using Chronic strings.
    # 'created_at is less than 2 weeks ago' is misleading, and
    # 'created_at is before 2 weeks ago' is much easier to understand.
    alt_predicate_label_or_default: (p, type, default_label) ->
      return default_label unless Ransack?.alt_predicates_i18n?
      alt_labels = {}
      switch type
        when "date", "datetime", "time"
          alt_labels = Ransack.alt_predicates_i18n["date"] || {}
        else
          alt_labels = Ransack.alt_predicates_i18n[type] || {}

      alt_labels[p] || default_label

    multi_query_changed: (e) ->
      target = $(e.currentTarget)

      # Fetch all query inputs for condition
      base_name = target.data('base-name')
      inputs = @element.find("input[name^=\"#{base_name}\"]")

      # Set the original query input to the first value before shifting inputs and values
      $(inputs[0]).val(e.val[0])

      inputs = inputs.slice(1)
      values = e.val.slice(1)

      # If value was added after the first value, then append extra input with added value
      if values.length && e.added
        @add_query_input(target, base_name, inputs.length + 1, e.added.id)

      else if e.removed
        # If value was removed, clear all extra inputs, then rebuild inputs for extra terms
        inputs.remove()
        $.each values, (i, v) =>
          @add_query_input(target, base_name, i + 1, v)

    setup_multi_query_input: (predicate_el, query_input, multi_id, selected_attribute) ->
      base_name = predicate_el.attr('name').slice(0, -3) + '[v]'
      base_id = predicate_el.attr('id').slice(0, -1)
      width = query_input.width() * 2
      width = 200 if width < 10
      query_input.after(
        $('<input class="ransack_query_multi" id="' + multi_id + '" ' +
          'style="width:' + width + 'px;" ' +
          'data-base-name="' + base_name + '" />'))

      query_select2_id = "#s2id_#{base_id}v_0_value"
      query_select2 = @element.find(query_select2_id)

      # Fetch all existing values
      inputs = @element.find("input[name^=\"#{base_name}\"]")
      values = $.map inputs, (el) -> el.value
      # Hide all query inputs
      inputs.hide()

      if Select2?
        # Find newly created input and setup Select2
        multi_query = @element.find('#' + multi_id)

        # Handle association columns with AJAX autocomplete
        if selected_attribute.data('ajax-url')
          # Set label to single association label, if anything was selected
          if query_select2.length && query_input.select2('data')
            query_input_data = query_input.select2('data')
            Ransack.value_field_labels[selected_attribute.val()] ||= {}
            Ransack.value_field_labels[selected_attribute.val()][query_input_data.id] = query_input_data.text

          @setup_select2_association(multi_query, selected_attribute, true)

        else
          if selected_attribute.data('select-options')
            # Setup Select2 with fixed multiple options
            @setup_select2_options(multi_query, selected_attribute, true)

          else
            # Setup Select2 with tagging support (can create options)
            multi_query.select2
              tags: []
              tokenSeparators: [',']
              formatNoMatches: (t) ->
                "Add a search term"

        multi_query.select2('val', values)

    setup_select2_association: (query_input, selected_attribute, multiple = false) ->
      selected_attribute_val = selected_attribute.val()
      # Set up Select2 for query input
      query_input.select2
        placeholder: "Search #{selected_attribute.data('ajax-entity')}"
        minimumInputLength: 1
        allowClear: true
        multiple: multiple
        ajax:
          url: selected_attribute.data('ajax-url')
          dataType: 'json'
          type: selected_attribute.data('ajax-type')
          data: (query, page) ->
            obj = {}
            obj[selected_attribute.data('ajax-key')] = query
            obj
          results: (data, page) ->
            {results: $.map(data, (text, id) -> {id: id, text: text}) }
        initSelection: (element, callback) ->
          data = []
          unless element.val().trim() == ""
            $(element.val().split(",")).each (i, val) ->
              label = Ransack.value_field_labels[selected_attribute_val]?[val]
              if label
                data.push {id: val, text: label}
              else
                data.push {id: val, text: val}
          if data.length
            callback(multiple and data or data[0])
          else
            # If no label could be found, clear value
            element.select2('val', '')

    setup_select2_options: (query_input, selected_attribute, multiple = false) ->
      query_input.select2
        data: selected_attribute.data('select-options')
        placeholder: "Please select a #{selected_attribute.text()}"
        allowClear: true
        multiple: multiple
        tokenSeparators: [',']
        formatNoMatches:
          if selected_attribute.data('select-options')
            (t) -> "No matches found."
          else
            (t) -> "Add a search term"
        initSelection: (element, callback) ->
          data = []
          unless element.val().trim() == ""
            $(element.val().split(",")).each (i, val) ->
              selected_attribute.data('select-options').each (option, i) ->
                if option.id == val
                  data.push {id: option.id, text: option.text}
                  return false  # Break out of inner each loop

          if data.length
            callback(multiple and data or data[0])
          else
            element.select2('val', '')

    add_query_input: (base_input, base_name, id, value) ->
      base_input.after $('<input name="'+base_name+'['+id+'][value]" '+
                         'value="'+value+'" style="display:none;" />')

    destroy_multi_input: (multi_input, selected_attribute_val) ->
      multi_input.select2('destroy').remove()
      # Also remove all extra inputs
      base_name = multi_input.data('base-name')
      inputs = @element.find("input[name^=\"#{base_name}\"]")
      inputs = inputs.slice(1)
      inputs.remove()

    form_submit: (e) ->
      @element.css({ opacity: 0.4 })
      true

    add_fields: (e) ->
      target  = $(e.currentTarget)
      type    = target.data("fieldType")
      content = target.data("content")
      new_id = new Date().getTime()
      regexp = new RegExp('new_' + type, 'g')
      target.before content.replace(regexp, new_id)
      prev_container = target.prev()

      if Select2?
        @init_select2(prev_container)

      if $.ransack.button_group_select?
        @init_button_group_select(prev_container)

      @store_initial_predicates(prev_container)
      # Fire change event on any new selects.
      prev_container.find("select").change()
      false

    remove_fields: (e) ->
      target    = $(e.currentTarget)
      container = target.closest('.fields')
      if (container.siblings().length > 1)
        container.remove()
      else
        container.parent().closest('.fields').remove()
      false

    store_initial_predicates: (container) ->
      # Store current predicates in data attribute
      predicate_select = container.find('select.ransack_predicate').first()
      unless predicate_select.data['predicates']
        predicates = []
        predicate_select.find('option').each (i, o) ->
          o = $(o)
          predicates.push [o.val(), o.text()]
        predicate_select.data['predicates'] = predicates

    init_select2: (container) ->
      container.find('select.ransack_predicate').select2
        width: '160px'
        formatNoMatches: (term) ->
          "Select a field first"

      container.find('select.ransack_attribute').select2
        width: '230px'
        placeholder: "Select a Field"
        allowClear: true
        formatSelection: (object, container) ->
          # If initializing and element is not present,
          # search for option element in original select tag
          if !object.element
            this.element.find('option').each (i, option) ->
              if option.value == object.id
                object.element = option
                return false

          # Return 'Model: field' unless column is on root model
          if $(object.element).data('root-model')
            object.text
          else
            group_label = $(object.element).parent().attr('label')
            # Avoid labels like 'Contact: Contact'
            if group_label == object.text
              object.text
            else if group_label?
              group_label + ': ' + object.text
            else
              object.text

      @element.find('select.ransack_sort').select2
        width: '230px'
        placeholder: "Select a Field"

    init_button_group_select: (containers) ->
      containers.find('select.ransack_combinator, select.ransack_sort_order').button_group_select()

    init_datetimepicker: (base_id) ->
      if $.ui?.timepicker?
        query_input = @element.find("input##{base_id}v_0_value")
        selected_attribute = @element.find("select##{base_id}a_0_name option:selected")

        # Clear any datepicker from query input first
        query_input.datepicker('destroy')

        datepicker_options =
          changeMonth: true
          constrainInput: false
          dateFormat: 'yy-mm-dd'
          buttonImage: "<%= asset_path('ransack_ui/calendar.png') %>"
          buttonImageOnly: true
          showOn: 'button'
          # Always prefer custom input text over selected date
          onClose: (date) -> $(this).val(date)

        # Show datepicker button for dates
        switch selected_attribute.data('type')
          when "date"
            query_input.datepicker(datepicker_options)
          when "datetime"
            query_input.datetimepicker(datepicker_options)
          when "time"
            query_input.datetimepicker $.extend(datepicker_options, {timeOnly: true})
) jQuery
