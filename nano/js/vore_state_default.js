
VoreStateDefaultClass.inheritsFrom(VoreStateClass);
var VoreStateDefault = new VoreStateDefaultClass();

function VoreStateDefaultClass() {

    this.key = 'default';

    //this.parent.constructor.call(this);

    this.key = this.key.toLowerCase();

    VoreStateManager.addState(this);
}