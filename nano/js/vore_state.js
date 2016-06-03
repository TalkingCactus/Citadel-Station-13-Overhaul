// This is the base state class, it is not to be used directly

function VoreStateClass() {
	/*if (typeof this.key != 'string' || !this.key.length)
	{
		alert('ERROR: Tried to create a state with an invalid state key: ' + this.key);
		return;
	}
	
    this.key = this.key.toLowerCase();
	
	VoreStateManager.addState(this);*/
}

VoreStateClass.prototype.key = null;
VoreStateClass.prototype.layoutRendered = false;
VoreStateClass.prototype.contentRendered = false;
VoreStateClass.prototype.mapInitialised = false;

VoreStateClass.prototype.isCurrent = function () {
    return VoreStateManager.getCurrentState() == this;
};

VoreStateClass.prototype.onAdd = function (previousState) {
    // Do not add code here, add it to the 'default' state (Vore_state_defaut.js) or create a new state and override this function

    VoreBaseCallbacks.addCallbacks();
    VoreBaseHelpers.addHelpers();
};

VoreStateClass.prototype.onRemove = function (nextState) {
    // Do not add code here, add it to the 'default' state (Vore_state_defaut.js) or create a new state and override this function

    VoreBaseCallbacks.removeCallbacks();
    VoreBaseHelpers.removeHelpers();
};

VoreStateClass.prototype.onBeforeUpdate = function (data) {
    // Do not add code here, add it to the 'default' state (Vore_state_defaut.js) or create a new state and override this function

    data = VoreStateManager.executeBeforeUpdateCallbacks(data);

    return data; // Return data to continue, return false to prevent onUpdate and onAfterUpdate
};

VoreStateClass.prototype.onUpdate = function (data) {
    // Do not add code here, add it to the 'default' state (Vore_state_defaut.js) or create a new state and override this function

    try
    {
        if (!this.layoutRendered || (data['config'].hasOwnProperty('autoUpdateLayout') && data['config']['autoUpdateLayout']))
        {
            $("#uiLayout").html(VoreTemplate.parse('layout', data)); // render the 'mail' template to the #mainTemplate div
            this.layoutRendered = true;
        }
        if (!this.contentRendered || (data['config'].hasOwnProperty('autoUpdateContent') && data['config']['autoUpdateContent']))
        {
            $("#uiContent").html(VoreTemplate.parse('main', data)); // render the 'mail' template to the #mainTemplate div
            this.contentRendered = true;
        }
        if (VoreTemplate.templateExists('mapContent'))
        {
            if (!this.mapInitialised)
            {
                // Add drag functionality to the map ui
                $('#uiMap').draggable({
                    handle : '#uiMapImage'
                });

                $('#uiMapTooltip')
                    .off('click')
                    .on('click', function (event) {
                        event.preventDefault();
                        $(this).fadeOut(400);
                    });

                this.mapInitialised = true;
            }

            $("#uiMapContent").html(VoreTemplate.parse('mapContent', data)); // render the 'mapContent' template to the #uiMapContent div

            if (data['config'].hasOwnProperty('showMap') && data['config']['showMap'])
            {
                $('#uiContent').addClass('hidden');
                $('#uiMapWrapper').removeClass('hidden');
            }
            else
            {
                $('#uiMapWrapper').addClass('hidden');
                $('#uiContent').removeClass('hidden');
            }
        }
        if (VoreTemplate.templateExists('mapHeader'))
        {
            $("#uiMapHeader").html(VoreTemplate.parse('mapHeader', data)); // render the 'mapHeader' template to the #uiMapHeader div
        }
        if (VoreTemplate.templateExists('mapFooter'))
        {
            $("#uiMapFooter").html(VoreTemplate.parse('mapFooter', data)); // render the 'mapFooter' template to the #uiMapFooter div
        }
    }
    catch(error)
    {
        alert('ERROR: An error occurred while rendering the UI: ' + error.message);
        return;
    }
};

VoreStateClass.prototype.onAfterUpdate = function (data) {
    // Do not add code here, add it to the 'default' state (Vore_state_defaut.js) or create a new state and override this function

    VoreStateManager.executeAfterUpdateCallbacks(data);
};

VoreStateClass.prototype.alertText = function (text) {
    // Do not add code here, add it to the 'default' state (Vore_state_defaut.js) or create a new state and override this function

    alert(text);
};


