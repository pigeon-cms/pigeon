var create = new Vue({
	el: '#create',
	data: {
		name: null,
		plural: null,
		fields: [],
		error: null
	},
	methods: {
		addField: function(type) {
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
		createCategory: function() {
			return {
				name: this.name,
				plural: (this.plural || this.name + 's'),
				template: this.fields
			}
		},
		handleSubmit: function(event) {
			const self = this
			let category = self.createCategory()

			var xhr = new XMLHttpRequest()
			xhr.open('POST', '/type/create', true)
			xhr.setRequestHeader('Content-Type', 'application/json; charset=UTF-8')
			xhr.send(JSON.stringify(category))

			xhr.onloadend = function () {
				const location = xhr.getResponseHeader('Location')
				if (location) {
					window.location.href = location
				}

				const response = JSON.parse(xhr.responseText)
				if (response.error) {
					self.handleError(response.reason)
				}
			}
		},
		handleError: function(error) {
			this.error = error
			if (error == 'A type with that name exists') {
				console.log('Plural error!') // TODO: place a red dot next to "plural" field
			}
		}
	}
})
