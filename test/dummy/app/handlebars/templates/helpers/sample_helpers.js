Handlebars.registerHelper('fullName', function(person) {
   return person.firstName + " " + person.lastName;
});

Handlebars.registerHelper('titleName', function(){
    return "The Right Honourable Anthony Eden";
});
