var create = new Vue({
	el: '#create',
	data: {
		fieldName: null,
		fieldPluralName: null,
		fields: []
	},
	methods: {
		addField: function(type) {
			console.log(type)
			this.fields.push({
				name: null,
				type: type,
				value: null,
				required: false
			})
		},
		removeField: function(field, event) {
			this.fields.splice( this.fields.indexOf(field), 1 )
		},
		handleSubmit: function(event) {
			console.log('Need to submit content: ' + JSON.stringify(this.fields))

			var xhr = new XMLHttpRequest()
			xhr.open('POST', '/type/create', true)
			xhr.setRequestHeader('Content-Type', 'application/json; charset=UTF-8')

			// send the collected data as JSON
			xhr.send(JSON.stringify(this.fields))

			xhr.onloadend = function () { }
		}
	}
})
