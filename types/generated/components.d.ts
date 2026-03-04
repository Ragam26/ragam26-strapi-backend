import type { Schema, Struct } from '@strapi/strapi';

export interface SharedContact extends Struct.ComponentSchema {
  collectionName: 'components_shared_contacts';
  info: {
    displayName: 'contact';
  };
  attributes: {
    name: Schema.Attribute.String;
    phoneNo: Schema.Attribute.String;
  };
}

declare module '@strapi/strapi' {
  export module Public {
    export interface ComponentSchemas {
      'shared.contact': SharedContact;
    }
  }
}
