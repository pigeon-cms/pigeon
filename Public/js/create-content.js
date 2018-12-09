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
				value: null
			})
		}
	}
})
