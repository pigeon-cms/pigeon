var create = new Vue({
	el: '#create',
	data: {
		fields: []
	},
	methods: {
		addField: function(type) {
			console.log(type)
			this.fields.push({
				name: null,
				type: type,
				value: null,
				defaultValue: null
			})
		},
		removeField: function(field, event) {
			this.fields.splice( this.fields.indexOf(field), 1 )
		}
	}
})
