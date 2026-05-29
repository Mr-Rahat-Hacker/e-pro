import { Injectable } from '@angular/core';
import { Observable, of } from 'rxjs';
import { InventoryItem } from '../../core/models/procurement.model';

@Injectable({ providedIn: 'root' })
export class InventoryService {
  list(): Observable<InventoryItem[]> {
    return of([
      { id: '1', sku: 'MRO-GLOVE-NITRILE-M', itemName: 'Nitrile Gloves Medium', warehouse: 'Chicago Main Warehouse', onHandQuantity: 100, reservedQuantity: 10, availableQuantity: 90, reorderPoint: 100 },
      { id: '2', sku: 'IT-SCANNER-HH', itemName: 'Handheld Barcode Scanner', warehouse: 'Chicago Main Warehouse', onHandQuantity: 42, reservedQuantity: 6, availableQuantity: 36, reorderPoint: 25 }
    ]);
  }
}
