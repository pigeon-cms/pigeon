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
		createCategory: function() {
			return {
				name: this.fieldName,
				plural: (this.fieldPluralName || this.fieldName + 's'),
				template: this.fields
			}
		},
		handleSubmit: function(event) {
			let category = this.createCategory()

			var xhr = new XMLHttpRequest()
			xhr.open('POST', '/type/create', true)
			xhr.setRequestHeader('Content-Type', 'application/json; charset=UTF-8')
			xhr.send(JSON.stringify(category))

			xhr.onloadend = function () { }
		}
	}
})
